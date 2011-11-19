Factory.define :meas_archive do |m|
  m.value 10.0
  m.raw 512
  m.time_from Time.now - 1.minute
  m.time_to Time.now
end