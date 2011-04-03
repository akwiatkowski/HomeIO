module ApplicationHelper

  def meas_value(meas_archive)
    np(meas_archive.value)
  end

  # Precision = 2
  def np(number)
    number_with_precision(number, :precision => 2)
  end

end
