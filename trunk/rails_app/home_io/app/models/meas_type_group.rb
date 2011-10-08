class MeasTypeGroup < ActiveRecord::Base
  has_many :meas_types
  validates_presence_of :name, :unit
end
