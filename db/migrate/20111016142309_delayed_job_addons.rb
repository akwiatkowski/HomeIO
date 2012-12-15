class DelayedJobAddons < ActiveRecord::Migration
  def up
    add_column :delayed_jobs, :job_class, :string
    add_column :delayed_jobs, :progress, :integer, :null => false, :default => 0
  end

  def down
    remove_column :delayed_jobs, :job_class
    remove_column :delayed_jobs, :progress
  end
end
