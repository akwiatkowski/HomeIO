Factory.define :meas_type do |mt|
  mt.sequence(:name) { |n| n || "meas_type_1" }
  mt.sequence(:unit) { |n| n || "V" }
end