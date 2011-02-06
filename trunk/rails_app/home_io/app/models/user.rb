class User < ActiveRecord::Base
  acts_as_authentic do |c|
    # for available options see documentation in: Authlogic::ActsAsAuthentic
    #c.my_config_option = my_value 
  end # block optional

end
