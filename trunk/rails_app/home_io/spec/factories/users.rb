Factory.define :user do |m|
  m.sequence(:login) { |n| "user_" + n.to_s }
  m.sequence(:email) {|n| "email_" + n.to_s + '@homeio.org' }

  #m.sequence(:crypted_password) { |n| Digest::SHA1.hexdigest("userA_" + n.to_s) }
  #m.sequence(:password_salt) { |n| Digest::SHA1.hexdigest("userB_" + n.to_s) }
  #m.sequence(:persistence_token) { |n| Digest::SHA1.hexdigest("userC_" + n.to_s) }
  #m.sequence(:single_access_token) { |n| Digest::SHA1.hexdigest("userD_" + n.to_s) }
  #m.sequence(:perishable_token) { |n| Digest::SHA1.hexdigest("userE_" + n.to_s) }

  m.sequence(:password) { |n| "password" + n.to_s }
  m.sequence(:password_confirmation) { |n| "password" + n.to_s }

  #m.login_count 0
  #m.failed_login_count 0
  #m.last_request_at Time.now - 1.year
  #m.current_login_at Time.now - 1.day
  #m.last_login_at Time.now - 1.hour
  #m.current_login_ip '192.168.0.1'
  #m.last_login_ip '192.168.0.1'

  m.admin false
end