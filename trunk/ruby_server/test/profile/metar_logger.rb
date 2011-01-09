require './lib/metar_logger.rb'
require 'ruby-prof'

# Profile the code
RubyProf.start
m = MetarLogger.instance
output = m.fetch_and_store_city('EPPO')
result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
#printer = RubyProf::CallTreePrinter.new(result)

f = File.new("metar_logger.profile","w")
printer.print(f, 0)
f.close