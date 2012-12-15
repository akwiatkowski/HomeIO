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

      3.times do
        Factory(:city)
        Factory(:meas_archive)
      end

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
      page.current_path.should == meas_caches_path

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
      url = "/cities?auth_token=#{token}"
      visit(url)

      City.all.each do |c|
        page.should have_content(c.name)
      end

      url = "/meas_caches?auth_token=#{token}"
      visit(url)
      MeasType.all.each do |m|
        meas_archive = MeasArchive.where(:meas_type_id => m.id).order('time_from DESC').first
        page.should have_content(meas_archive.value.to_i.to_s)
      end

      url = "/meas_caches"
      visit(url)
      MeasType.all.each do |m|
        meas_archive = MeasArchive.where(:meas_type_id => m.id).order('time_from DESC').first
        page.should_not have_content(meas_archive.value.to_i.to_s)
      end

    end

  end

end