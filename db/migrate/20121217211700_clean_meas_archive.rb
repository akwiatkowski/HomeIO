class CleanMeasArchive < ActiveRecord::Migration
  def up
    remove_column :meas_archives, :_time_from_ms
    remove_column :meas_archives, :_time_to_ms
  end

  def down
    add_column :meas_archives, :_time_from_ms, :integer
    add_column :meas_archives, :_time_to_ms, :integer
  end
end
