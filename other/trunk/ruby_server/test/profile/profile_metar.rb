require './lib/metar_logger.rb'
Thread.abort_on_exception = true
m = MetarLogger.instance
output = m.fetch_and_store