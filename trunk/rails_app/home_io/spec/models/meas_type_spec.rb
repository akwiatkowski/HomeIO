describe 'MeasType', :type => :model do

  context 'simple test' do
    before(:each) do
      @meas_archives_count = 10
      @mt = Factory(:meas_type, :name => 'current')
      @meas_archives_count.times do
        m = Factory(:meas_archive, :value => rand(50).to_f, :meas_type_id => @mt.id)
        @mt.meas_archives << m
      end
    end

    it "should have proper relations" do
      @mt.meas_archives.size.should == @meas_archives_count
      @mt.should.kind_of? MeasType
      @mt.meas_archives.first.should.kind_of? MeasArchive
    end

    it 'has proper scopes' do
      MeasType.all.each do |mt|
        mt.name_human.should.kind_of? String
      end
    end


  end
end