Factory.define :meas_archive do |m|
  #m.raw 100
  #m.value 10.0
  #m.time_from Time.now - 1.minute
  #m.time_to Time.now - 1.minute + 5.seconds
  ##m.meas_type Factory(:meas_type, :name => 'current')
  #m.meas_type_id Factory(:meas_type, :name => 'current').id

  m.sequence(:value) {|n| n || 10.0 }
  m.sequence(:raw) {|n| n || 512 }
  m.sequence(:time_from) {|n| n || Time.now - 1.minute }
  m.sequence(:time_to) {|n| n || Time.now }
  
end