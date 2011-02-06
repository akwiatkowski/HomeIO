class UserSession < Authlogic::Session::Base
  login_field :login
  password_field :password
end