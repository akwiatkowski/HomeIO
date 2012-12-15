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
        50.times do
          ma = Factory(:meas_archive, :meas_type => mt)
        end
      end

      # initial capybara
      visit("/")
      click_link "Sign in"

      page.current_path.should == new_user_session_path

      fill_in 'user_email', :with => 'user@user.pl'
      fill_in 'user_password', :with => 'user@user.pl'

      click_button "Sign in"

      # page.current_path.should == root_path
      page.current_path.should == meas_caches_path
    end

    it "meas archives simple test" do
      # meas caches and archives
      MeasType.all.each do |m|

        # archive
        within("#meas_types_#{m.id}_archive") do
          click_link m.name_human
        end
        page.current_path.should == meas_type_meas_archives_path(m)
        page.should have_selector("h2", :content => "Archived measurements - #{m.name_human}")
        page.status_code.should == 200 unless Capybara.current_driver == :selenium # not supported in selenium

        prev_url = page.current_path
        # checking XML
        within("#utils") do
          click_link 'XML'
          page.status_code.should == 200 unless Capybara.current_driver == :selenium # not supported in selenium
          xml_doc = Nokogiri::XML(page.body.to_s)
          # very simple xml validation
          xml_doc.children.size.should == 1
        end
        # after
        visit(prev_url)

        # checking SVG
        within("#utils") do
          click_link 'Graph (SVG)'
          page.status_code.should == 200 unless Capybara.current_driver == :selenium # not supported in selenium
          xml_doc = Nokogiri::XML(page.body.to_s)
          # very simple xml validation
          xml_doc.children.size.should > 0
        end
        visit(prev_url)
      end


      # that is all
      click_link "Logout"
      page.current_path.should == root_path
    end

  end
end