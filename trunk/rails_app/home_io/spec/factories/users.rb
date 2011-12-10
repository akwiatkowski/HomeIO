# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :user do |f|
  f.sequence(:email) { |n| "user_#{n}@homeio.org" }
  f.password '1234567890'
end
