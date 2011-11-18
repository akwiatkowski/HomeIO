Factory.define :action_type do |mt|
  mt.sequence(:name) { |n| n || "action_type_1" }
end