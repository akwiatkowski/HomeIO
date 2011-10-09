class MeasTypeGroupAddParams < ActiveRecord::Migration
  def self.up
    add_column :meas_type_groups, :y_min, :float, :null => true
    add_column :meas_type_groups, :y_max, :float, :null => true
    add_column :meas_type_groups, :y_interval, :float, :null => true
  end

  def self.down
    remove_column :meas_type_groups, :y_min
    remove_column :meas_type_groups, :y_max
    remove_column :meas_type_groups, :y_interval
  end
end
