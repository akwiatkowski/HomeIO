class RemoveOverseerParams < ActiveRecord::Migration
  def change
    drop_table :overseer_params
    add_column :overseers, :params, :string
  end
end
