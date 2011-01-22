require './lib/utils/adv_log.rb'
require './lib/supervisor/task.rb'

# One server task, queue element

class CommQueueTask

  # After this interval after sending result task can be deleted
  TASK_LIFETIME_AFTER_SENT = 2*60
  # After this interval after finishing task can be deleted
  TASK_LIFETIME_AFTER_DONE = 30*60
  # Min lifetime
  TASK_LIFETIME_MIN = 10

  # Create self, hash-like object
  def initialize( t )
    # internal Task
    @t = Task.factory( t )
  end

  # Accesor for task
  def task
    return @t
  end

  # Is new?, not done yet
  def is_new?
    @t.is_new?
  end

  # Is ready?
  def is_ready?
    @t.is_ready?
  end

  # Was sent?
  def is_sent?
    @t.is_sent?
  end

  # Client can fetch result ot task
  def finished?
    @t.finished?
  end

  # Is processed right now?
  def is_in_process?
    @t.is_in_process?
  end

  # Was task finished?
  def finished?
    @t.finished?
  end

  # Set task is beign processed right now
  def set_in_proccess!
    @t.set_in_proccess!
  end

  # Set task id sone
  def set_done!
    @t.set_done!
  end

  # Set task result was sent
  def set_sent!
    @t.set_sent!
  end

  def response
    @t.response
  end

  # For setting response by server
  def response=(r)
    @t.response = r
  end

  def command
    return @t.command
  end

  def params
    return @t.params
  end

  # Is command with Proc
  def type_proc?
    @t.type_proc?
  end

  # Is command normal, not Proc
  def type_normal?
    @t.type_normal?
  end

  # When task was finished, Time or nil
  def time_finished
    @t.time_finished
  end

  # When task response was sent, Time or nil
  def time_sent
    @t.time_sent
  end

  # Run Proc command
  def run_proc( klass_instance )
    @t.run_proc( klass_instance )
  end

  # Is task ready to be deleted
  def old?
    if self.is_sent?
      # current time is bigger than finish + interval
      if Time.now > ( self.time_sent + TASK_LIFETIME_AFTER_SENT )
        return true
      else
        return false
      end
    elsif self.is_done?
      # current time is bigger than finish + interval
      if Time.now > ( self.time_finished + TASK_LIFETIME_AFTER_DONE )
        return true
      else
        return false
      end

    else
      # not read
      return false
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

  # Very hurry task, is processed outside queue
  def process_now?
    @t.process_now?
  end

  # Id used for fetching response
  def fetch_id
    @t.fetch_id
  end

  # Generate id for fetching it later
  def added_on_queue!
    @t.generate_id!
    @t.set_response_added!
  end


end
