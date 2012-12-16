class AddMeasTypeSerialized < ActiveRecord::Migration
  def change
    add_column :meas_types, :params, :string
  end
end
