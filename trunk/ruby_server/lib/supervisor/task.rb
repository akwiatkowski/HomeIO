# Simple task
# From it is created CommQueueTask

class Task


  # When task was created, Time
  attr_reader :time_new

  # When task was started, Time or nil
  attr_reader :time_started

  # When task was finished, Time or nil
  attr_reader :time_finished

  # When task response was sent, Time or nil
  attr_reader :time_sent

  # When taks can't be processed @error is true
  attr_reader :error

  # Command sent to server
  attr_accessor :command

  # Additional parameters
  attr_accessor :params

  # Result from server
  attr_accessor :response

  # Result from server
  attr_accessor :now

  # Time of processing command
  attr_reader :process_time

  # Status
  attr_reader :status

  DONE = :done
  NEW = :new
  SENT = :sent
  IN_PROCESS = :in_process

  # Id used for fetching response later
  attr_reader :fetch_id

  # Fetch status - status for fetch
  attr_reader :fetch_status

  FETCH_OK = :ok
  FETCH_NOT_READY = :not_ready
  FETCH_NOT_FOUND = :not_found
  FETCH_NO_ID = :no_id

  def set_fetch_ok!
    @fetch_status = FETCH_OK
  end

  def set_fetch_not_ready!
    @fetch_status = FETCH_NOT_READY
  end

  def set_fetch_not_found!
    @fetch_status = FETCH_NOT_FOUND
  end

  def set_fetch_no_id!
    @fetch_status = FETCH_NO_ID
  end

  # Used for wait loop
  def fetch_is_ready?
    if FETCH_NOT_READY == @fetch_status
      return false
    elsif FETCH_OK == @fetch_status
      return true
    else
      puts "Fetch ERROR, status #{@fetch_status}"
      return true
    end
  end

  # Reason for error
  attr_reader :reason

  # Additional parameter for error
  attr_reader :error_params


  # Create new task
  def initialize( h = {} )
    # main command
    @command = h[:command]
    @params = h[:params]

    # default tasks are processed inside queue
    @now = false
    @now = h[:now] if true == h[:now]

    @status = NEW
    @status = h[:status] unless h[:status].nil?

    @error = false
    @time_new = Time.now
  end

  # Create new Task from hash or return Task object
  def self.factory( obj )
    if obj.kind_of?(Task)
      return obj
    end

    if obj.kind_of?(Hash)
      return Task.new( obj )
    end

    return nil
  end

  # Is new?, not done yet
  def is_new?
    return true if self.status == NEW
    return false
  end

  # Is ready?
  def is_ready?
    return true if self.status == DONE
    return false
  end

  # Was sent?
  def is_sent?
    return true if self.status == SENT
    return false
  end

  # Is processed right now?
  def is_in_process?
    return true if self.status == IN_PROCESS
    return false
  end

  # Was task finished - ready to fetch?
  def finished?
    return true if is_ready? or is_sent?
    return false
  end

  # Set task is beign processed right now
  def set_in_proccess!
    @status = IN_PROCESS
    @time_started = Time.now
  end

  # Set task id sone
  def set_done!
    @status = DONE
    @time_finished = Time.now

    if not @time_finished.nil? and not@time_started.nil?
      @process_time = @time_finished.to_f - @time_started.to_f
    else
      @process_time = nil
    end
  end

  # Set task result was sent
  def set_sent!
    @status = SENT
    @time_sent = Time.now

    if @time_finished.nil?
      @time_finished = Time.now
      @process_time = nil
    end
  end

  # Taks can not be processed
  def set_error!( reason = :unknown, error_params = nil )
    set_done!
    @error = true
    @error_reason = reason
    @error_params = error_params
  end

  # Is command with Proc
  def type_proc?
    self.command.kind_of?(Proc)
  end

  # Is command normal, not Proc
  def type_normal?
    self.command.kind_of?(Symbol) or self.command.kind_of?(Hash)
  end

  # Run Proc command
  def run_proc( klass_instance )
    return nil if false == self.type_proc?

    begin
      self.response = command.call( klass_instance )
    rescue => e
      self.response = nil
      set_error!( :proc_failed, e.inspect )

      puts e.inspect
      puts e.backtrace
      log_error( self, e, "task.inspect #{self.inspect}" )
    end
  end

  # Very hurry task, is processed outside queue
  def process_now?
    return @now
  end

  # Generate id for fetching it later
  def generate_id!
    @fetch_id = self.object_id
  end

  # Set response that task was added to queue
  def set_response_added!
    @response = :added
  end

  

end
