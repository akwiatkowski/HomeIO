# require 'capybara/rspec'
describe "simple navigating website", :type => :request, :js => true do
  context 'simple navigating website' do
    before(:each) do
      @u = Factory(
        :user,
        :email => "user@user.pl",
        :password => "user@user.pl",
        :password_confirmation => "user@user.pl"
      )
      @u.save!
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

  end
end