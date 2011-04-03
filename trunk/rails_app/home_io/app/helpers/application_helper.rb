module ApplicationHelper

  def meas_value(meas_archive)
    number_with_precision(meas_archive.value, :precision => 2)
  end

end
