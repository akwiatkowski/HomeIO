class CreateOverseerParameters < ActiveRecord::Migration
  def self.up
    create_table :overseer_parameters do |t|
      t.references :overseer
      t.string :key, :null => false
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :overseer_parameters
  end
end
