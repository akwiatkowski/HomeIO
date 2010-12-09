# Some new methods

class Date

  # Obliczanie ostatniego dnia miesiąca
  def self.last_day_of_the_month yyyy, mm
    d = new yyyy, mm
    d += 42                  # warp into the next month
    new(d.year, d.month) - 1 # back off one day from first of that month
  end

end