# require 'capybara/rspec'
describe "getting access via sign in or token", :type => :request, :js => true do
  context 'sign in testing' do
    before(:each) do
      # create user using factory
      @u = Factory(
        :user,
        :login => "user124",
        :email => "user@user.pl",
        :password => "user@user.pl",
        :password_confirmation => "user@user.pl"
      )

      @u.save!
      puts @u.inspect
      @u.valid?
      puts @u.errors.to_yaml
      puts "^"*100
      puts User.all.to_yaml
      puts "^"*100

      # register manualy
      visit('/')
      click_link "Register"
      page.current_path.should == new_user_path #'/users/new'

      within("#new_user") do
        fill_in 'user_login', :with => 'user123'
        fill_in 'user_email', :with => 'test@test.pl'
        fill_in 'user_password', :with => 'user@user.pl'
        fill_in 'user_password_confirmation', :with => 'user@user.pl'
      end

      puts "^"*100
      puts User.all.to_yaml
      puts "^"*100


      click_button 'Register'
      page.current_path.should == account_path

      within("#account_logout") do
        click_link "Logout"
      end

      puts "*"*100
      puts User.all.to_yaml
      puts "*"*100

    end

    it "sign me in standard" do
      visit("/")
      click_link "Sign in"

      page.current_path.should == new_user_session_path

      fill_in 'user_session_login', :with => 'user124'
      fill_in 'user_session_password', :with => 'user@user.pl'

      click_button "Login"

      page.current_path.should == meas_caches_path

      click_link "Logout"

      page.current_path.should == root_path


    end


    it "sign me in using token" do
      token = user.single_access_token
      # url = "/meas_caches.json?token=#{token}"
      url = "/cities?token=#{token}"
      visit(url)
    end

  end

end