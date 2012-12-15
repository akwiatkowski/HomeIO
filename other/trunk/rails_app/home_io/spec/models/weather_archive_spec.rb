describe 'WeatherArchive', :type => :model do
  before(:each) do
    @city = Factory(:city, :name => "city_sample")
  end

  it "should test factory girl and relations" do
    wa = Factory(
      :weather_archive,
      :city => @city
    )
    wa.city.should == @city
  end

  it "should be predicted record" do
    wa = Factory(
      :weather_archive,
      :time_from => Time.now + 1.hour,
      :time_to => Time.now + 2.hours,
      :city => @city
    )
    wa.predicted?.should
  end

end