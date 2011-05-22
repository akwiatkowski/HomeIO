class FixOverseerForeignKeys < ActiveRecord::Migration
  def self.up
    Overseer.transaction do
      remove_foreign_key :overseer_parameters, :overseers
      add_foreign_key :overseer_parameters, :overseers, :dependent => :delete
    end
  end

  def self.down
    Overseer.transaction do
      remove_foreign_key :overseer_parameters, :overseers
      add_foreign_key :overseer_parameters, :overseers, :dependent => :restrict
    end
  end
end
