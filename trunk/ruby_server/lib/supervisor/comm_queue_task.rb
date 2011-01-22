require './lib/utils/adv_log.rb'

# One server task, queue element

class CommQueueTask

  DONE = :done
  NEW = :new
  SENT = :sent
  IN_PROCESS = :in_process

  # After this interval after process finished taks will be deleted
  TASK_LIFETIME = 2*60

  # Task should be in queue after process at least for this interval
  TASK_LIFETIME_MIN = 5

  # When task was created, Time
  attr_reader :time_new

  # When task was started, Time or nil
  attr_reader :time_started

  # When task was finished, Time or nil
  attr_reader :time_finished

  # When task response was sent, Time or nil
  attr_reader :time_sent


  # Create self, hash-like object
  def initialize( h )
    @time_new = Time.now

    # internal hash
    @h = h
    # so it's new by default
    @h[:status] = NEW
  end

  # Czy nowe, niewykonane
  def is_new?
    return true if @h[:status] == NEW
    return false
  end

  # Czy jest gotowe, przetowrzone
  def is_ready?
    return true if @h[:status] == DONE
    return false
  end

  # Czy został wysłany
  def is_sent?
    return true if @h[:status] == SENT
    return false
  end

  # Is processed right now?
  def is_in_process?
    return true if @h[:status] == IN_PROCESS
    return false
  end

  # Was taks finished?
  def finished?
    return true if is_ready? or is_sent?
    return false
  end

  # Set when tast is beign processed now
  def set_in_proccess!
    @h[:status] = IN_PROCESS
    @time_started = Time.now
  end

  # Ustaw na zakończone
  def set_done!
    @h[:status] = DONE
    @time_finished = Time.now
    
    @h[:process_time] = @time_finished - @time_started
  end

  # Ustaw na wysłane
  def set_sent!
    @h[:status] = SENT
    @time_sent = Time.now
  end

  def response
    return @h[:response]
  end

  def command
    return @h[:command]
  end

  # Time cost of processing command
  attr_reader :process_time

  # Is command with Proc
  def type_proc?
    self.command.kind_of?(Proc)
  end

  # Run Proc command
  def run_proc( klass_instance )
    return nil if false == self.type_proc?

    begin
      self.response = command.call( klass_instance )
    rescue => e
      self.response = nil
      # TODO add accesor
      @h[:error] = true

      puts e.inspect
      puts e.backtrace
      log_error( self, e, "task.inspect #{self.inspect}" )
    end
  end

  # Is command normal, not Proc
  def type_normal?
    self.command.kind_of?(Symbol) or self.command.kind_of?(Symbol)
  end

  # Set response in internal hash
  def response=( resp )
    @h[:response] = resp
  end

  # Is task ready to be deleted
  def old?
    if self.is_sent?
      # current time is bigger than finish + interval
      if Time.now > ( self.time_finished + TASK_LIFETIME )
        return true
      else
        return false
      end
    else
      # not read
      return nil
    end
  end

  # Is task not ready to deletet because of big queue
  def new?
    if self.is_ready?
      # current time is less than finish + interval
      if Time.now <= ( self.time_finished + TASK_LIFETIME_MIN )
        return true
      else
        return false
      end
    else
      # is alsa fresh
      return true
    end
  end

  # Very hurry task
  def process_now?
    return true if true == @h[:now]
    return false
  end

  # Return internal hash for replying
  #
  # Security notice, object can be manipulated by due to old memory computers
  # I prefer not to use too much clone, some responses could be massive
  def to_h_for_sending
    set_sent!
    return @h
  end

  # Id used for fetching response
  def fetch_id
    return @h[:id]
  end


end
