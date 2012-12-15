class MeasTypeAddUnit < ActiveRecord::Migration
  def self.up
    add_column :meas_types, :unit, :string, :null => false, :default => '?', :limit => 32
  end

  def self.down
    remove_column :meas_types, :unit
  end
end
