# Some new methods

class Time

  # Nowa metoda wyświetlania czasu
  def to_human
    return self.strftime("%Y-%m-%d %H:%M:%S")
  end

  # Ustawia początek danego miesiąca
  def utc_begin_of_month
    t = Time.utc( self.year, self.month, 1, 0, 0, 0)
    #puts "* " + t.to_s
    return t
  end

  # Ilość dni w miesiącu
  def self.days_in_month( month, year = Time.now.year )
    return ((Date.new(year, month, 1) >> 1) - 1).day
  end

  # Ustawia koniec danego miesiąca
  def utc_end_of_month
    days = Time.days_in_month( self.month )
    t = Time.utc( self.year, self.month, days, 0, 0, 0)
    # przejdź na koniec danego dnia
    t += 24*3600 - 1
    #puts "- " + t.to_s
    return t
  end

end