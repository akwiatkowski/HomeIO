require 'plasma_applet'

Qt::WebSettings::globalSettings.setAttribute(Qt::WebSettings::PluginsEnabled, true)
Qt::WebSettings::globalSettings.setAttribute(Qt::WebSettings::JavascriptEnabled, true)

# http://techbase.kde.org/Development/Tutorials/Plasma/Ruby/SimplePasteApplet#Getting_started
# https://github.com/iiska/uniresta-plasmoid/blob/master/contents/code/main.rb

module HomeIO
  class Main < PlasmaScripting::Applet
    def initialize(parent)
      super parent
    end

    private
    
    def init
      self.has_configuration_interface = false
      self.aspect_ratio_mode = Plasma::IgnoreAspectRatio

      resize 440, 320
      
      @layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self
      self.layout = @layout

      @web_page = Plasma::WebView.new(self)

      #set white BG to ignore system palette
      @web_page.page.setPalette Qt::Palette.new(Qt::Color.new 255,255,255)	
      @layout.add_item @web_page

      @web_page.url = KDE::Url.new("http://pl.no-ip.org:24/meas_caches.txt?auth_token=UXcJt42xRGYpGDRpJLtv")

      #Thread.new{ self.reload }
      #reload
    end

    def reload
      loop do
        sleep 30
        @web_page.reload
      end
    end

    public
  end
end
