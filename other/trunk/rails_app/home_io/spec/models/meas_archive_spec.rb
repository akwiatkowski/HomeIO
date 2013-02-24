describe 'MeasArchive', :type => :model do

  context 'simple test' do
    before(:each) do
      @meas_archives_count = 10
      @mt = Factory(:meas_type, :name => 'current')
      @meas_archives_count.times do
        m = Factory(:meas_archive, :value => rand(50).to_f, :meas_type_id => @mt.id)
        @mt.meas_archives << m
      end
      @ma = @mt.meas_archives.first
    end

    it "should have proper attributes types" do
      @ma.meas_type.should.kind_of? MeasType
      @ma.time_from.should.kind_of? Time
      @ma.time_to.should.kind_of? Time
      @ma.time_from.should.kind_of? Time
      @ma.value.should.kind_of? Float
    end

    it 'has proper attributes and accessors' do
      MeasType.all.each do |mt|
        mt.name_human.should.kind_of? String
      end
    end

    it 'shouldnt allow to store_to_buffer meas without value' do
      m = MeasArchive.new
      m.meas_type_id = @mt.id
      m.save.should == false
      m.errors.size.should > 0
    end

    it 'should check scopes' do
       # not worky
       #MeasArchive.time_from( Time.now ).all
    end

  end

end