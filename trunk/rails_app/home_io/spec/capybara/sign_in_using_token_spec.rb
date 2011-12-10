# require 'capybara/rspec'
describe "getting access via sign in or token", :type => :request, :js => true do
  context 'sign in testing' do
    before(:each) do
      # create user using factory
      @u2 = Factory(
        :user,
        :email => "user2@user.pl",
        :password => "user@user.pl",
        :password_confirmation => "user@user.pl"
      )
      @u2.save!

      # register manually
      visit('/')
      click_link "Sign up"
      page.current_path.should == new_user_registration_path #'/users/new'

      within("#user_new") do
        fill_in 'user_email', :with => 'user@user.pl'
        fill_in 'user_password', :with => 'user@user.pl'
        fill_in 'user_password_confirmation', :with => 'user@user.pl'
      end

      click_button 'Sign up'
      page.current_path.should == root_path

      within("#account_logout") do
        click_link "Logout"
      end

      @u = User.find_by_email('user@user.pl')
    end

    it "sign me in standard" do
      visit("/")
      click_link "Sign in"

      page.current_path.should == new_user_session_path

      fill_in 'user_email', :with => 'user@user.pl'
      fill_in 'user_password', :with => 'user@user.pl'

      click_button "Sign in"

      page.current_path.should == meas_caches_path

      click_link "Logout"

      page.current_path.should == root_path


    end


    it "sign me in using token" do
      @u.reload
      token = @u.authentication_token

      puts @u.inspect

      # url = "/meas_caches.json?auth_token=#{token}"
      url = "/cities?auth_token=#{token}"
      visit(url)
      
    end

  end

end