describe "ApplicationController", :type => :request, :js => true do
  context 'changing device type' do
    before(:each) do
    end

    it "sign me in standard" do
      mobile_shoulds = [
        'homeio_mobile_layout'
      ]
      desktop_shoulds = [
        'jquery-ui',
        'raphael',
        'g.line'
      ]


      visit("/")
      click_link "Mobile"
      page.current_path.should == "/mobile"
      visit("/")

      mobile_shoulds.each do |s|
        page.html.to_s.include?(s).should == true
      end
      desktop_shoulds.each do |s|
        page.html.to_s.include?(s).should == false
      end

      click_link "Desktop"
      page.current_path.should == "/desktop"
      visit("/")
      desktop_shoulds.each do |s|
        page.html.to_s.include?(s).should == true
      end
      mobile_shoulds.each do |s|
        page.html.to_s.include?(s).should == false
      end

    end

  end

end