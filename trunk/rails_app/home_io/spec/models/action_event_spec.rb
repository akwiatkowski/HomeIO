describe 'ActionEvent', :type => :model do

  context 'simple test' do
    before(:each) do
      @model_instances_count = 10
      @model_instance = Factory(:action_type, :name => 'current')

      @model_instances = Array.new
      @model_instances << @model_instance

      @action_events_count_per_type = 2

      (0...@model_instances_count).each do |i|
        m = Factory(:action_type, :name => "action_type_" + i.to_s)

        @action_events_count_per_type.times do
          me = Factory(
            :action_event,
            :action_type_id => m.id
          )
          me.valid?
          me.errors.size.should == 0

          m.action_events << me
        end

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