Factory.define :overseer do |m|
  m.sequence(:name) { |n| "overseer_" + n.to_s }
  m.klass 'AverageProcOverseer'
  m.active true

  m.association :user, :factory => :user
  m.hit_count 0
  m.last_hit nil
end