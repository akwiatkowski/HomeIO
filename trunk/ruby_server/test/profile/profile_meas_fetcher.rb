require 'lib/measurements/measurement_fetcher'
require 'lib/utils/start_threaded'

# ruby-prof -p call_tree -f kcache.grind test/profile/profile_meas_fetcher.rb

mf = MeasurementFetcher.instance
sleep 120
mf.meas_array.stop

StartThreaded.kill_all_sub_threads

