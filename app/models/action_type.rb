# Action types

class ActionType < ActiveRecord::Base
  has_many :action_events

  validates_presence_of :name
  validates_uniqueness_of :name

  set_inheritance_column :sti_type
end
