class FixMeasArchiveIndex < ActiveRecord::Migration
  def self.up
    add_index :meas_archives, [:meas_type_id, :time_from], :unique => true, :name => 'meas_archive_meat_type_time_index2'
    remove_index :meas_archives, :name => 'meas_archive_meat_type_time_index'
  end

  def self.down
    add_index :meas_archives, [:meas_type_id, :time_from, :_time_from_ms], :unique => true, :name => 'meas_archive_meat_type_time_index'
    remove_index :meas_archives, :name => 'meas_archive_meat_type_time_index2'
  end
end
