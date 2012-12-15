class MeasTypeGroup < ActiveRecord::Base
  has_and_belongs_to_many :meas_types
  validates_presence_of :name, :unit

  # alias
  def types
    self.meas_types
  end

end
