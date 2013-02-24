require 'spec_helper'

describe HomeIoServer::ActionManager do
  it "simple" do
    am = HomeIoServer::ActionManager.new
    res = am.execute_by_name('start_total_brake')

    puts res.inspect
  end
end
