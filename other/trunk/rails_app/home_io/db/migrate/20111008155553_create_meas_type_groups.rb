class CreateMeasTypeGroups < ActiveRecord::Migration
  def self.up
    create_table :meas_type_groups do |t|
      t.string :name, :null => false, :default => ''
      t.string :unit, :null => false, :default => ''

      t.timestamps
    end

    add_column :meas_types, :meas_type_group_id, :integer
    add_foreign_key :meas_types, :meas_type_groups, :dependent => :update
  end

  def self.down
    remove_foreign_key :meas_types, :meas_type_groups
    remove_column :meas_types, :meas_type_group_id
    drop_table :meas_type_groups
  end
end
