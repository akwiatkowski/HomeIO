describe 'City', :type => :model do

  context 'simple test' do
    before(:each) do
      @model_instances_count = 10
      @model_instance = Factory(:city, :name => 'current')

      @model_instances = Array.new
      @model_instances << @model_instance

      (0...@model_instances_count).each do |i|
        m = Factory(:city, :name => "city_" + i.to_s)
        @model_instances << m
      end

      @wp = Factory(:weather_provider, :name => "wp1")
    end

    it "should check basics" do
      City.all.each do |c|
        c.should.kind_of? City
      end
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
        :weather_provider_id => @wp.id
      )
      city.update_search_flags
      city.weather_class.should == WeatherArchive

      city.weather_metar_archives << Factory(
        :weather_metar_archive
      )
      city.update_search_flags
      city.weather_class.should == WeatherMetarArchive
    end

  end
end