require 'lib/home_io_meas'

Thread.abort_on_exception = true

a = HomeIoMeas.instance
a.thread_fetch

sleep 10
