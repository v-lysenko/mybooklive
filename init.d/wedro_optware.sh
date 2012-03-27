#!/bin/sh

start() {
if [ -d /opt/etc/init.d ]; then
  echo "Launching Optware initialization scripts"
  for f in /opt/etc/init.d/S* ; do
    [ -x $f ] && $f start
  done
else
  echo "error: /opt/etc/init.d directory not found" >&2
  exit 1
fi
}

stop() {
if [ -d /opt/etc/init.d ]; then
  echo "Launching Optware termination scripts"
  for f in /opt/etc/init.d/K* ; do
    [ -x $f ] && $f stop
  done
else
  echo "error: /opt/etc/init.d directory not found" >&2
  exit 1
fi
}

restart() {
    stop
    start
}

case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    restart)
        restart
    ;;
    cleanup)
    ;;
    *)
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac

exit $?
