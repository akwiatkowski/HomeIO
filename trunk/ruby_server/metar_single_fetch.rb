require 'lib/metar_tools'
require 'lib/metar_logger'

Thread.abort_on_exception = true
config = MetarTools.load_config
# without starting
config[:start] = false
m = MetarLogger.new( config )
m.do_once