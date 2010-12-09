# Some new methods

class Object

  # Wypełnij zerami aż do długości
  def to_s2( places )
    tmp = self.to_s

    while( tmp.size < places )
      tmp = "0" + tmp
    end

    return tmp
  end

  def to_s_round( places )
    if self.nil?
      return nil
    end

    tmp = ( self * (10 ** places ) ).round.to_f
    tmp /= (10.0 ** places )
    return tmp
  end

end