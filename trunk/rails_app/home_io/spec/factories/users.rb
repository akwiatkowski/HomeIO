Factory.define :user do |m|
  m.sequence(:login) { |n| "user_" + n.to_s }
  m.sequence(:email) {|n| "email_" + n.to_s + '@homeio.org' }

  m.sequence(:password) { |n| "password" + n.to_s }
  m.sequence(:password_confirmation) { |n| "password" + n.to_s }

  m.admin false
end