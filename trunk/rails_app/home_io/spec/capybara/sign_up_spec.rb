# require 'capybara/rspec'
describe "the sign up process", :type => :request, :js => true do

  it "register me and log out" do
    visit('/')
    click_link "Register"
    page.current_path.should == new_user_path #'/users/new'

    within("#new_user") do
      fill_in 'user_login', :with => 'new_user'
      fill_in 'user_email', :with => 'test@test.pl'
      fill_in 'user_password', :with => 'password'
      fill_in 'user_password_confirmation', :with => 'password'
      #fill_in 'Login', :with => 'new_user'
      #fill_in 'Email', :with => 'test@test.pl'
      #fill_in 'Password', :with => 'password'
      #fill_in 'Password confirmation', :with => 'password'
    end
    click_button 'Register'
    page.current_path.should == account_path

    within("#account_logout") do
      click_link "Logout"
    end
    page.current_path.should == root_path
  end

end