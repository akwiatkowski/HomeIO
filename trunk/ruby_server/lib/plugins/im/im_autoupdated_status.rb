require 'singleton'
require './lib/plugins/im/im_bots.rb'
require './lib/storage/extractors/extractor_active_record.rb'
Dir["./lib/plugins/im/bots/*.rb"].each {|file| require file }

class ImAutoupdatedStatus
  include Singleton

  # start x seconds later
  LATER_START = 4 # was good enough
  #LATER_START = 15 # should be production ready

  # autochange status every x seconds
  #CHANGE_STATUS_INTERVAL = 15*60
  CHANGE_STATUS_INTERVAL = 10

  # Run thread with autoupdate status
  def run_autoupdater
    puts "IM autoupdated status was run"
    sleep( LATER_START )
    @bots = ImBots.instance.bots

    Thread.abort_on_exception=true
    Thread.new{
      autoupdater_thread
    }
  end

  private

  def autoupdater_thread
    loop do
      # create status
      data_str = current_status
      str = "HomeIO | #{data_str}"
      @bots.each do |b|
        # puts "Autoupdated #{b.class}, #{b.class::STATUS_AVAIL.inspect} - '#{str}'"
        b.change_status_only_text( str )
      end
      sleep( CHANGE_STATUS_INTERVAL )
    end
  end

  # Generate current status
  def current_status
    current_status_poznan_current_weather
  end

  # Generate current weather in Poznań
  # Sample use :]
  def current_status_poznan_current_weather
    poznan_hash = ExtractorActiveRecord.instance.get_last_metar('Poznań')
    return "Poznań, #{poznan_hash[:time].localtime.to_time_human}, #{poznan_hash[:temperature].to_s_round( 1 )} oC, #{poznan_hash[:wind].to_s_round( 1 )} m/s"
  end

end
