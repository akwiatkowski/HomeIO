class AddSampleHomeArchiveTypes < ActiveRecord::Migration
  def self.up
    HomeArchiveType.transaction do
      ["total_grid_power_consumed", "furnace_fuel_consumed", "furnace_unprocessed_output"].each do |name|
        HomeArchiveType.find_or_create_by_name(name)
      end
    end
  end
end
