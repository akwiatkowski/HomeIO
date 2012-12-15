# Measurements

class MeasArchive < ActiveRecord::Base
  belongs_to :meas_type
  validates_presence_of :value, :time_from, :time_to, :meas_type
end
