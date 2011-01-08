# One server task, queue element

class CommQueueTask < Hash

  DONE = :done
  NEW = :new
  SENT = :sent
  IN_PROCESS = :in_process

  # Tworzy coś podobnego do Hasha
  def initialize( h )
    self.merge!( h )
  end

  # Czy nowe, niewykonane
  def is_new?
    return true if self[:status] == NEW
    return false
  end

  # Czy jest gotowe, przetowrzone
  def is_ready?
    return true if self[:status] == DONE
    return false
  end

  # Czy został wysłany
  def is_sent?
    return true if self[:status] == SENT
    return false
  end

  # Is processed right now?
  def is_in_process?
    return true if self[:status] == IN_PROCESS
    return false
  end

  # Set when tast is beign processed now
  def set_in_proccess!
    self[:status] = IN_PROCESS
  end

  # Ustaw na zakończone
  def set_done!
    self[:status] = DONE
  end

  # Ustaw na wysłane
  def set_sent!
    self[:status] = SENT
  end

  def response
    return self[:response]
  end

  def command
    return self[:command]
  end

end
