class ActionTypesUser < ActiveRecord::Base
  set_table_name 'action_types_users'
  belongs_to :action_type
  belongs_to :users

  # TODO some composite primary keys?
end
