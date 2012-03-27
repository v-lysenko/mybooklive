#!/bin/sh

CUSTOM="/DataVolume/custom"
C_OPT="$CUSTOM/opt"
C_ROOT="$CUSTOM/root"
C_VAR="$CUSTOM/var"

###################################################

start() {
if [ -z "$(mount | grep '\/opt')" ]; then
  echo "Mounting OPTWARE"
  mount --bind $C_OPT /opt
else
  echo "Error: OPTWARE seems already mounted" >&2
fi

if [ -z "$(mount | grep '\/root')" ]; then
  echo "Mounting ROOT"
  mount --bind $C_ROOT /root
else
  echo "Error: ROOT seems already mounted" >&2
fi

if [ -z "$(mount | grep '\/var\/opt')" ]; then
  echo "Mounting VAR/OPT"
  mount --bind $C_VAR /var/opt
else
  echo "Error: VAR/OPT seems already mounted" >&2
fi

}

stop() {
if [ -n "$(mount | grep '\/opt')" ]; then
  echo "Unmounting OPTWARE"
  umount /opt
else
  echo "Error: OPTWARE seems already unmounted" >&2
fi

if [ -n "$(mount | grep '\/root')" ]; then
  echo "Unmounting ROOT"
  umount /root
else
  echo "Error: ROOT seems already unmounted" >&2
fi

if [ -n "$(mount | grep '\/var\/opt')" ]; then
  echo "Unmounting VAR/OPT"
  umount /var/opt
else
  echo "Error: VAR/OPT seems already unmounted" >&2
fi

}


restart() {
    /etc/init.d/wedro_chroot.sh stop
    stop
    start
    /etc/init.d/wedro_chroot.sh start
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
