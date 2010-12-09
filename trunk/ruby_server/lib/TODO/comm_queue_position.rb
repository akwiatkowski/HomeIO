# Pozycja na liście kolejki

class CommQueuePosition < Hash
  
  # Tworzy coś podobnego do Hasha
  def initialize( h )
    self.merge!( h )
  end

  # Czy nowe, niewykonane
  def is_new?
    return true if self[:status] == :new
    return false
  end

  # Czy jest gotowe, przetowrzone
  def is_ready?
    return true if self[:status] == :done
    return false

    #return true if self[:ready] == :new
    #return false
  end

  # Czy został wysłany
  def is_sent?
    return true if self[:status] == :sent
    return false
  end

  # Ustaw na zakończone
  def set_done!
    self[:status] = :done
  end

  # Ustaw na wysłane
  def set_sent!
    self[:status] = :sent
  end

end
