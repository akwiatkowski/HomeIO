class AddSampleHomeArchiveTypes < ActiveRecord::Migration
  def self.up
    HomeArchiveType.transaction do
      # sample parameters
      HomeArchiveType.find_or_create_by_name("total_grid_power_consumed")
      HomeArchiveType.find_or_create_by_name("furnace_fuel_consumed")
      HomeArchiveType.find_or_create_by_name("furnace_unprocessed_output")
    end
  end

  def self.down
    HomeArchiveType.transaction do

    end
  end
end
