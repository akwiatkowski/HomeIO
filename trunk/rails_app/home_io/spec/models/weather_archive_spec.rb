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
end