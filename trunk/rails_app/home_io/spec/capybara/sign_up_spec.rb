# require 'capybara/rspec'
describe "the sign up process", :type => :request, :js => true do

  it "register me and log out" do
    visit('/')
    click_link "Sign up"
    page.current_path.should == new_user_registration_path

    within("#user_new") do
      fill_in 'user_email', :with => 'user@user.pl'
      fill_in 'user_password', :with => 'user@user.pl'
      fill_in 'user_password_confirmation', :with => 'user@user.pl'
      #fill_in 'Email', :with => 'user@user.pl'
      #fill_in 'Password', :with => 'user@user.pl'
      #fill_in 'Password confirmation', :with => 'user@user.pl'
    end
    click_button 'Sign up'
    page.current_path.should == root_path

    within("#account_logout") do
      click_link "Logout"
    end
    page.current_path.should == root_path
  end

end