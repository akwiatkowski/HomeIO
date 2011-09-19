describe 'User', :type => :model do
  it "should be in any roles assigned to it" do
    user = User.new
    user.assign_role("assigned role")
    user.should be_in_role("assigned role")
  end
end