class AddSampleHomeArchiveTypes < ActiveRecord::Migration
  def self.up
    HomeArchiveType.transaction do
      # sample parameters
      #HomeArchiveType.find_or_create_by_name("total_grid_power_consumed")
      #HomeArchiveType.find_or_create_by_name("furnace_fuel_consumed")
      #HomeArchiveType.find_or_create_by_name("furnace_unprocessed_output")

      ["total_grid_power_consumed", "furnace_fuel_consumed", "furnace_unprocessed_output"].each do |name|
        HomeArchiveType.create!(:name => name) if HomeArchiveType.find(:first, :conditions => { :name => name }).nil?
      end

    end
  end

  def self.down
    HomeArchiveType.transaction do

    end
  end
end
