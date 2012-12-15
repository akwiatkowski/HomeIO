class ActionTypesUser < ActiveRecord::Base
  set_table_name 'action_types_users'
  belongs_to :action_type
  belongs_to :users

  set_primary_keys :user_id, :action_type_id
end
