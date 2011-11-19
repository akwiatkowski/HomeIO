Factory.define :action_event do |m|
  m.time Time.now
  m.other_info nil
  m.error_status false

  m.association :action_type
  m.association :executed_by_user, :factory => :user
  m.association :executed_by_overseer, :factory => :overseer
end