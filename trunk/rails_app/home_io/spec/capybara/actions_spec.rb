describe "ActionController", :type => :request, :js => true do
  context 'simple' do
    before(:each) do
      pass = '1'*10
      @u = Factory(
        :user,
        :password => pass,
        :admin => true
      )

      10.times do
        Factory(:action_event)
      end

      visit("/")
      click_link "Sign in"

      page.current_path.should == new_user_session_path

      fill_in 'user_email', :with => @u.email #'user@user.pl'
      fill_in 'user_password', :with => pass

      click_button "Sign in"

      page.current_path.should == meas_caches_path
    end

    it "simple" do
      click_link 'Actions'
      page.current_path.should == action_types_path

      click_link 'Events'
      puts page.current_path

      # TODO
    end
  end

end