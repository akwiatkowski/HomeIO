Factory.define :action_type do |mt|
  mt.sequence(:name) { |n| "action_type_" + n.to_s }
end