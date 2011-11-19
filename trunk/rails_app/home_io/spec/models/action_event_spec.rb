describe 'ActionEvent', :type => :model do

  context 'simple test' do
    before(:each) do
      @model_instances_count = 10
      @model_instances = Array.new

      @action_events_count_per_type = 2

      (0...@model_instances_count).each do |i|
        m = Factory(:action_type)

        @action_events_count_per_type.times do
          me = Factory(
            :action_event,
            :action_type => m
          )
          me.errors.size.should == 0
          m.action_events << me
        end
        m.save!
        m.reload

        m.action_events.size.should == @action_events_count_per_type

        @model_instances << m
      end

    end

    it "should check basics" do
      ActionType.all.each do |at|
        at.action_events.size.should == @action_events_count_per_type
      end
    end

  end
end