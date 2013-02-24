class RemoveOverseerParams < ActiveRecord::Migration
  def up
    drop_table :overseer_parameters
    add_column :overseers, :params, :string
  end

  def down
    create_table :overseer_parameters
    remove_column :overseers, :params, :string
  end
end
