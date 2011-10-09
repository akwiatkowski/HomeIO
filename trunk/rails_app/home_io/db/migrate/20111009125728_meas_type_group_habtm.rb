class MeasTypeGroupHabtm < ActiveRecord::Migration
  def self.up
    remove_foreign_key :meas_types, :meas_type_groups
    remove_column :meas_types, :meas_type_group_id

    create_table :meas_type_groups_meas_types, :id => false do |t|
      t.integer :meas_type_id, :null => false
      t.integer :meas_type_group_id, :null => false
    end
    # no FK, its'n not that important
  end

  def self.down
    drop_table :meas_type_groups_meas_types
  end
end
