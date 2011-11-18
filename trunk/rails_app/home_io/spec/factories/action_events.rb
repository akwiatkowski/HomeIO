Factory.define :action_event do |m|
  m.sequence(:time) { |n| n || Time.now }
  m.sequence(:other_info) {|n| n || nil }
  m.sequence(:error_status) {|n| n.nil? ? false : n }
  m.sequence(:action_type_id) {|n| n }
  m.sequence(:user_id) {|n| n.nil? ? nil : n }
  m.sequence(:overseer_id) {|n| n.nil? ? nil : n }
  
end