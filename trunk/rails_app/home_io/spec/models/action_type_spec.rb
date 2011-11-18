describe 'ActionType', :type => :model do

  context 'simple test' do
    before(:each) do
      @model_instances_count = 10
      @model_instance = Factory(:action_type, :name => 'current')

      @model_instances = Array.new
      @model_instances << @model_instance


      (0...@model_instances_count).each do |i|
        m = Factory(:action_type, :name => "action_type_" + i.to_s)
        @model_instances << m
      end
    end

    it "should check basics" do
      ActionType.all.each do |at|
        at.name_human.should.kind_of? String
      end
    end

  end
end