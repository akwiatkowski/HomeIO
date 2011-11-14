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

    it "should have proper relations" do
      @ma.meas_type.should.kind_of? MeasType
      @ma.time_from.should.kind_of? Time
    end

    it 'has proper attributes and accessors' do
      MeasType.all.each do |mt|
        mt.name_human.should.kind_of? String
      end
    end


  end
end