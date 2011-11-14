describe 'MeasType', :type => :model do

  def _setup
    @mt = Factory(:meas_type, :name => 'current')
    10.times do
      m = Factory(:meas_archive, :value => rand(50).to_f, :meas_type_id => @mt.id)
      @mt.meas_archives << m
    end
  end

  setup do
  end


  it "should have proper relations" do
    mt = MeasType.new
    mt.meas_archives.size.should == 0
    #mt.meas_archives.should_have(0).things
    
  end

  it 'should test simple relations 2' do
    _setup
    puts @mt.meas_archives.to_yaml
  end

end