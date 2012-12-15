#! /bin/bash

# TODO: use this template someday

### BEGIN INIT INFO
# Provides:          HomeIO backend
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts HomeIO backend
# Description:       starts HomeIO backend using start-stop-daemon
### END INIT INFO

# path to app
APP_PATH=/opt/HomeIO/trunk/ruby_server/

# path to paster bin
DAEMON=<path to pylons workingenv>/bin/paster

# startup args
DAEMON_OPTS=" serve --log-file <my logfile> --server-name=main production.ini"

# script name
NAME=<my_rc_script.sh>

DESC=HomeIO

# pylons user
RUN_AS=<user to switch to after startup>

PID_FILE=/var/run/paster.pid

############### END EDIT ME ##################

test -x $DAEMON || exit 0

set -e

case "$1" in
  start)
        echo -n "Starting $DESC: "
        start-stop-daemon -d $APP_PATH -c $RUN_AS --start --background --pidfile $PID_FILE  --make-pidfile --exec $DAEMON -- $DAEMON_OPTS
        echo "$NAME."
        ;;
  stop)
        echo -n "Stopping $DESC: "
        start-stop-daemon --stop --pidfile $PID_FILE
        echo "$NAME."
        ;;

  restart|force-reload)
        echo -n "Restarting $DESC: "
        start-stop-daemon --stop --pidfile $PID_FILE
        sleep 1
        start-stop-daemon -d $APP_PATH -c $RUN_AS --start --background --pidfile $PID_FILE  --make-pidfile --exec $DAEMON -- $DAEMON_OPTS
        echo "$NAME."
        ;;
  *)
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop|restart|force-reload}" >&2
        exit 1
        ;;
esac

exit 0