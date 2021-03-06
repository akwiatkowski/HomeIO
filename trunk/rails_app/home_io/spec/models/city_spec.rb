describe 'City', :type => :model do

  it "should check basics" do
    m = Factory(:city)
    n = Factory(:city)

    m.valid?.should
    n.valid?.should
  end

  context 'simple test' do
    before(:each) do
      @model_instances_count = 10
      @model_instance = Factory(:city, :name => 'current')

      @model_instances = Array.new
      @model_instances << @model_instance

      (0...@model_instances_count).each do |i|
        m = Factory(:city)
        @model_instances << m
      end

      @wp = Factory(:weather_provider, :name => "wp1")
    end

    it "should check basics" do
      City.all.each do |c|
        c.should.kind_of? City
      end

      City.local.should.kind_of? Array
    end

    it 'should check validation' do
      c = City.new
      c.name = 'bad city'
      c.country = 'country'
      c.valid?.should_not

      c.lat = 1.0
      c.lon = 1.0
      c.valid?.should
    end

    it 'should check weather class' do
      city = @model_instances.first
      city.weather_class.should.nil?

      city.weather_archives << Factory(
        :weather_archive,
        :weather_provider => @wp,
        :city => city
      )
      city.update_search_flags
      city.weather_class.should == WeatherArchive

      city.weather_metar_archives << Factory(
        :weather_metar_archive,
        :city => city
      )
      city.update_search_flags
      city.weather_class.should == WeatherMetarArchive
    end

    it 'should check weather class when updated using method for all cities' do
      city = @model_instances.first
      city.weather_class.should.nil?

      city.weather_archives << Factory(
        :weather_archive,
        :weather_provider => @wp,
        :city => city
      )
      city.save!
      City.update_search_flags_for_all_cities
      city.reload
      city.weather_class.should == WeatherArchive
      city.weather_metar_archives << Factory(
        :weather_metar_archive,
        :city => city
      )
      City.update_search_flags_for_all_cities
      city.reload
      city.weather_class.should == WeatherMetarArchive
    end

    it 'should be able to get last weather conditions' do
      City.get_all_weather.should.kind_of? Array
    end

  end
  
  context 'weather fetching tests' do
    before(:each) do
      @wp = Factory(:weather_provider, :name => "wp1")

      @model_instances_count = 10
      @model_instance = Factory(:city, :name => 'current')

      @model_instances = Array.new
      @model_instances << @model_instance

      @weathers_count = 15

      (0...@model_instances_count).each do |i|
        m = Factory(:city, :name => "city_" + i.to_s + Time.now.usec.to_s)
        @model_instances << m

        # maybe not so optimized..
        (0...@weathers_count).each do |j|
          # adding weather every 2, and metar every 3
          if i % 2 == 1
            m.weather_archives << Factory(
              :weather_archive,
              :weather_provider => @wp,
              :city => m
            )
          end

          if i % 3 == 1
            m.weather_metar_archives << Factory(
              :weather_metar_archive,
              :city => m
            )
          end
        end
        # end weather addition

      end
      # and cities addition

      City.update_search_flags_for_all_cities
    end

    it 'should be able to get last weather conditions' do
      last_weathers = City.get_all_weather
      last_weathers.should.kind_of? Array

      last_weathers.each do |w|
        w.city.weather_class.should == w.class
      end
    end

    it 'calculate average attributes' do
      last_weathers = City.get_all_weather
      city = last_weathers.first.city
      last_weathers_for_city = city.last_weather(@weathers_count)
      last_weathers_for_city.size.should == @weathers_count

      # temperatures
      temperatures = last_weathers_for_city.collect { |w| w.temperature }
      avg = temperatures.sum.to_f / temperatures.size.to_f

      avg_2 = City.adv_attr_avg(
        'temperature',
        Time.now.to_i,
        [city],
        Time.at(0)
      )

      avg.should be_within(0.01).of(avg_2)

      #wind
      winds = last_weathers_for_city.collect { |w| w.wind }
      avg = winds.sum.to_f / winds.size.to_f

      avg_2 = City.adv_attr_avg(
        'wind',
        Time.now.to_i,
        [city],
        Time.at(0)
      )

      avg.should be_within(0.01).of(avg_2)
    end

  end
  

end