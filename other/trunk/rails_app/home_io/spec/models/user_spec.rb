describe 'User', :type => :model do
  it "should create instance" do
    user = User.new
    user.should be_an_instance_of(User)

    u = Factory(:user)
    puts u.valid?
  end
end