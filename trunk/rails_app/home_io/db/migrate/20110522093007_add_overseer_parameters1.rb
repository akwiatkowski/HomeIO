class AddOverseerParameters1 < ActiveRecord::Migration
  def self.up
    add_column :overseers, :hit_count, :integer, :null => false, :default => 0
    add_column :overseers, :last_hit, :datetime, :null => true
  end

  def self.down
    remove_column :overseers, :hit_count
    remove_column :overseers, :last_hit
  end
end
