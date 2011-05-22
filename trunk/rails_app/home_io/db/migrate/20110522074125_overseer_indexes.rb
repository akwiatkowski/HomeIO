class OverseerIndexes < ActiveRecord::Migration
  def self.up
    add_index :overseers, :name, :unique => true
    add_foreign_key :overseer_parameters, :overseers, :dependent => :cascade
  end

  def self.down
    remove_foreign_key :overseer_parameters, :overseers
  end
end
