class AddActionTypeParams < ActiveRecord::Migration
  def change
    add_column :action_types, :params, :string
  end
end
