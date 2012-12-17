# Measurements

class MeasArchive < ActiveRecord::Base
  belongs_to :meas_type

  validates_presence_of :value, :time_from, :time_to, :meas_type

  scope :time_from, lambda { |from| where ["time_from >= ?", from] }
  scope :time_to, lambda { |tto| where ["time_to <= ?", tto] }
  scope :meas_type_id, lambda { |id| where(:meas_type_id => id) unless id == 'all' }

  attr_accessible :raw, :value, :time_from, :time_to
end
