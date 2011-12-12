# require 'capybara/rspec'
describe "MeasArchivesController", :type => :request, :js => true do
  context 'simple test' do
    before(:each) do
      @u = Factory(
        :user,
        :email => "user@user.pl",
        :password => "user@user.pl",
        :password_confirmation => "user@user.pl"
      )
      @u.save!

      5.times do
        mt = Factory(:meas_type)
        5.times do
          ma = Factory(:meas_archive, :meas_type => mt)
        end
      end

      visit("/")
      click_link "Sign in"

      page.current_path.should == new_user_session_path

      fill_in 'user_email', :with => 'user@user.pl'
      fill_in 'user_password', :with => 'user@user.pl'

      click_button "Sign in"

      # page.current_path.should == root_path
      page.current_path.should == meas_caches_path

    end

    it "simple test" do
      # navigation phase

      click_link 'Measurements'
      page.current_path.should == meas_caches_path
      page.should have_selector("h2", :content => 'Current measurements')

      click_link 'Current values'
      page.current_path.should == meas_caches_path
      page.should have_selector("h2", :content => 'Current measurements')

      # meas caches and archives
      MeasType.all.each do |m|
        # cache
        within("#meas_types_#{m.id}_cache") do
          click_link m.name_human
        end
        page.current_path.should == meas_type_meas_cache_path(m)
        page.should have_selector("h2", :content => "Current measurements - #{m.name_human}")

        # archive
        within("#meas_types_#{m.id}_archive") do
          click_link m.name_human
        end
        page.current_path.should == meas_type_meas_archives_path(m)
        page.should have_selector("h2", :content => "Archived measurements - #{m.name_human}")

        prev_url = page.current_path
        # checking XML
        within("#utils") do
          click_link 'XML'
          #require 'rexml/document'
          #data = REXML::Document.new(page.to_s)
          #puts data.elements.size
          #puts data.to_yaml
          puts page.to_s
        end
        # after
        visit(prev_url)


      end

      click_link 'Current values (txt)'
      page.current_path.should == meas_caches_path(:txt)
      page.to_s.lines.count.should == MeasType.all.count + 2
      visit("/") # this was only a text file


      # that is all

      click_link "Logout"

      page.current_path.should == root_path
    end

  end
end