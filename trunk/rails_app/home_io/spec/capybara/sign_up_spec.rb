require 'capybara/rspec'

describe "the signup process", :type => :request, :js => true do
  before :each do
    #User.make(:email => 'user@example.com', :password => 'caplin')
    visit('/users/new')
    
  end

  it "signs me in" do
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
    #sleep 10
    click_button 'Register'
    puts page.inspect
    
    sleep 10

    #puts response.inspect
    #sleep 1
    #page.should have_content('has been submitted')
    #sleep 5

  end
end