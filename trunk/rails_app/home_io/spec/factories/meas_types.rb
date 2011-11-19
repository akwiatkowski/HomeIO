Factory.define :meas_type do |mt|
  mt.sequence(:name) { |n| "meas_type_" + n.to_s }
  mt.unit "V"
end