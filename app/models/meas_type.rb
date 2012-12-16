# Measurement types

class MeasType < ActiveRecord::Base
  has_and_belongs_to_many :meas_type_group
  has_many :meas_archives

  validates_presence_of :name
  validates_uniqueness_of :name

  set_inheritance_column :sti_type
  serialize :params, Hash
end
