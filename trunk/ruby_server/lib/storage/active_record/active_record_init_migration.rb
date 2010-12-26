require './lib/storage/active_record/models/city.rb'

# TODO
# przeliczanie wszystkich miast z yamli pogodowych, i dodawanie jako
# nowe jeżeli odległość od dodanego jest mniejsza niż ileś
#
# rozważyć klucze obce

class ActiveRecordInitMigration < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base. transaction do
      create_table :cities do |t|
        t.column :name, :string, :null => false
        t.column :country, :string, :null => false
        t.column :metar, :string, :null => true
        t.column :lat, :float, :null => false
        t.column :lon, :float, :null => false
        # from predefined location
        t.column :calculated_distance, :float, :null => true
      end
    
      create_table :meas_archives do |t|
        t.column :time_from, :datetime, :null => false
        t.column :time_to, :datetime, :null => false
        # when time with microseconds is needed
        #t.column :time_from_us, :integer, :null => false, :default => 0
        #t.column :time_to_us, :integer, :null => false
        t.column :value, :float, :null => false
        t.references :meas_type
        # TODO zrobić meas_types
      end

      create_table :meas_types do |t|
        t.column :type, :string, :limit => 16, :null => false
        # TODO add other fields later
        t.timestamps
      end
    
      create_table :weather_archives do |t|
        t.column :time_from, :datetime, :null => false
        t.column :time_to, :datetime, :null => false

        t.column :temperature, :float, :null => true
        t.column :wind, :float, :null => true
        t.column :pressure, :float, :null => true
        t.column :rain, :float, :null => true
        t.column :snow, :float, :null => true
      
        t.timestamps
        t.references :city
        t.references :weather_provider
        # TODO zrobić to
      end

      create_table :weather_metar_archives do |t|
        t.column :time_from, :datetime, :null => false
        t.column :time_to, :datetime, :null => false

        t.column :temperature, :float, :null => true
        t.column :wind, :float, :null => true
        t.column :pressure, :float, :null => true
        t.column :rain_metar, :integer, :null => true
        t.column :snow_metar, :integer, :null => true
        t.column :raw, :string, :null => true, :limit => 255

        t.timestamps
        t.references :city
      end

      # cities
      add_index :cities, [:lat, :lon], :unique => true
      add_index :cities, [:name, :country], :unique => true
      # meas
      add_index :meas_archives, [:meas_type_id, :time_from], :unique => true
      # weather
      add_index :weather_archives, [:weather_provider_id, :city_id, :time_from, :time_to], :unique => true, :name => 'weather_archives_index'
      # metar
      add_index :weather_metar_archives, [:time_from, :raw], :unique => true, :name => 'weather_metar_archives_raw_uniq_index'
      add_index :weather_metar_archives, [:time_from, :city_id], :unique => true, :name => 'weather_metar_archives_raw_city_uniq_index'
    end

    City.create_from_config
  end

  def self.down
    drop_table :cities
    drop_table :meas_archives
    drop_table :meas_types
    drop_table :weather_archives
    drop_table :weather_metar_archives
  end
end
