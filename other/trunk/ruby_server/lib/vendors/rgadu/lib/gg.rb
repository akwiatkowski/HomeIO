#!/usr/bin/ruby

=begin rdoc
Prosta implementacja protokolu Gadu-Gadu w czystym Ruby oparta na watkach i zdarzeniach. Pozwala bardzo szybko stworzyc dzialajacego klienta GG. Zawiera serwer DCC, obsluguje przesylanie plikow protokolem DCC w wersjach 6 i 7.
=end
class GG
	def initialize(uin, password, params={})
		server = params[:server] || '217.17.45.146'
		port = params[:port] || 8074
		dccport = params[:dccport] || 0
		contacts = params[:contacts] || []
		status = params[:status] || :avail
		description = params[:description]
		friendsonly = params[:friendsonly] ? true : false
		version = (params[:version] || 6.0).to_f

		@uin=uin
		@dccport=dccport
		@socket=TCPSocket.new(server, port)
		type, length = read_header
		if type!=0x01
			raise "Packet not recognized"
		end
		seed=read_body(length, 'L')[0]
		if dccport > 0
			@dcc = DCCServer.new(dccport, uin)
			localip=@socket.addr[3].split('.').collect {|x| x.to_i }.pack('C4').unpack('L')[0]
		else
			localip=0
		end
		if version >= 7.7
			protocol = 0x2a
		elsif version >= 7.6
			protocol = 0x29
		elsif version >= 7
			protocol = 0x24
		else
			protocol = 0x20
		end
		if description
			status = TO_STATUS_DESCRIPTION[status] or raise "Wrong status"
		else
			status = TO_STATUS[status] or raise "Wrong status"
		end
		if friendsonly
			status = status | 0x8000
		end
		if version >= 7
			hash = Digest::SHA1.digest(password + [seed].pack('L'))
			if description
				write(0x19, 'LCa64LLCLSLSCCa*C', uin, 0x02, hash, status, protocol, 0x00, localip, dccport, localip, dccport, 0x00, 0xbe, description, 0)
			else
				write(0x19, 'LCa64LLCLSLSCC', uin, 0x02, hash, status, protocol, 0x00, localip, dccport, localip, dccport, 0x00, 0xbe)
			end
		else
			hash = gg_login_hash(password, seed)
			if description
				write(0x15, 'LLLLCLSLSCCa*C', uin, hash, status, 0x20, 0x00, localip, dccport, localip, dccport, 0x00, 0xbe, description, 0)
			else
				write(0x15, 'LLLLCLSLSCC', uin, hash, status, 0x20, 0x00, localip, dccport, localip, dccport, 0x00, 0xbe)
			end
		end
		type, length = read_header
		read_body(length)
		unless type==0x03 or type==0x14
			raise "Authorization failed"
		end
		if contacts.length > 0
			contactpacket = []
			contacts.each {|contact| contactpacket.push(contact, 0x03) }
			write(0x10, 'LC'*contacts.length, *contactpacket)
		else
			write(0x12, '')
		end
		@action, @status, @search_reply, @dcc_code, @dcc_action, @dcc_client_action = {}, {}, {}, [], {}, {}
		contacts.each {|contact| @status[contact] = {:status => :notavail} }
		@action_thread, @dcc_client, @dcc_client_thread = [], [], []
		@action[0x0a] = lambda {|sender, seq, time, cl, message| msg_received(sender, seq, time, cl, message) }
		@action[0x02] = lambda {|uin, status, description| status_changed(uin, status, description) }
		@action[0x0f] = @action[0x17] = lambda {|uin, status, ip, port, version, x, y, description| status_changed(uin, status, description, ip, port, version) }
		@action[0x0c] = lambda {|uin, status, ip, port, version, x, description| status_changed(uin, status, description, ip, port, version) }
		# modified, was errors
    #@action[0x11] = @action[0x18] = lambda {|uin, status, ip, port, version, imgsize, x, descsize, description| status_changed(uin, status, description, ip, port, version) }
		@action[0x0e] = lambda {|type, seq, response| @search_reply[seq] = response }
		@action[0x23] = lambda {|type, code| @dcc_code << code }
		@action[0x21] = lambda {|uin, code, offset, x| @dcc_action[code].call(offset) if @dcc_action[code] }
		@action[0x22] = lambda {|uin, code, reason| @dcc_action[code].call(-1) if @dcc_action[code] }
		@action[0x1f] = lambda do |uin, x, code, ip_port, y|
			if action = @dcc_client_action[code]
				@dcc_client_action.delete(code)
				action.call(*(ip_port.chomp(0.chr).split(' ')))
			end
		end
		@read_loop = Thread.new do
			loop do
				sleep 0.1
				read or break
			end
		end
		@ping_loop = Thread.new do
			loop do
				sleep 180
				ping
			end
		end
	end

  def msg_received(sender, seq, time, cl, message)
		if cl == 0x10 and message.chomp(0.chr) == 2.chr
			if @dcc_recv_action and ip = get_ip(sender) and port = get_port(sender) and port > 1
				@dcc_client_thread << Thread.new(ip, port, @uin, sender, @dcc_recv_action) do |ip, port, uin1, uin2, dcc_recv_action|
					begin
						client = DCCClient.new(ip, port, uin1, uin2)
						@dcc_client << client
						client.client_recv {|uin, filename, filesize| dcc_recv_action.call(uin, filename, filesize) }
					rescue
						warn "Error: #{$!}"
					end
				end
			end
		else
      # my modification to not not destroy server then @msg_action has
      # errors
      begin
        @msg_action.call(sender, Time.at(time), message.chomp(0.chr)) if @msg_action
      rescue => e
        puts e.inspect
        puts e.backtrace
      end
		end
	end

  def read_header
		begin
      type=@socket.read(4).unpack('L')[0]
      length=@socket.read(4).unpack('L')[0]
      return type, length
    rescue
      # my modification to be alive after gg server restart
      sleep 5
      return nil, 0
    end
	end
end
