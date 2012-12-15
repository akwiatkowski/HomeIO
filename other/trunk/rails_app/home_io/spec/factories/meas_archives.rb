Factory.define :meas_archive do |m|
  x = + rand(50)
  
  m.value 10.0 + x.to_f / 10.0
  m.raw 512 + x

  m.sequence(:time_from) { |n| Time.now - 30.minutes + 2 * n.seconds }
  m.sequence(:time_to) { |n| Time.now - 30.minutes + 2 * n.seconds + 1 }

  m._time_from_ms 0
  m._time_to_ms 0

  m.association :meas_type
end