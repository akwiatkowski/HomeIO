class AddActionEventOverseerKey < ActiveRecord::Migration
  def self.up
    change_table :action_events do |t|
      t.references :overseer
    end
  end

  def self.down
    remove_column :action_events, :overseer_id
  end
end
