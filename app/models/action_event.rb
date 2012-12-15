# Events of actions executions

class ActionEvent < ActiveRecord::Base
  belongs_to :action_type
  belongs_to :executed_by_user, :class_name => "User", :foreign_key => :user_id
  belongs_to :executed_by_overseer, :class_name => "Overseer", :foreign_key => :overseer_id

  validates_presence_of :time

  acts_as_commentable

  scope :time_from, lambda { |from| where ["time >= ?", tf] }
  scope :time_to, lambda { |tto| where ["time <= ?", tt] }
  scope :action_type_id, lambda { |id| where(:action_type_id => id) unless id == 'all' }
end
