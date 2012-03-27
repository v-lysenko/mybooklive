#/bin/bash

CUSTOM_VAR='/var/opt'
CHROOT_DIR="$CUSTOM_VAR/chroot"
CHROOT_SERVICES="$(cat /root/.etc/chroot-services)"


if [ -z "$(mount | grep '\/DataVolume\/custom\/var')" ]; then
    echo "CHROOT sems unmounted. exiting"
    exit 1
fi

#######################################################################

start() {
    mount --bind /DataVolume/shares/common $CHROOT_DIR/mnt

    chroot $CHROOT_DIR mount -t proc none /proc -o rw,noexec,nosuid,nodev
    chroot $CHROOT_DIR mount -t sysfs none /sys -o rw,noexec,nosuid,nodev
    chroot $CHROOT_DIR mount -t devpts none /dev/pts -o rw,noexec,nosuid,gid=5,mode=620

    for ITEM in $CHROOT_SERVICES; do
        chroot $CHROOT_DIR service $ITEM start
    done
}

stop() {
    for ITEM in $CHROOT_SERVICES; do
        chroot $CHROOT_DIR service $ITEM stop
    done

    chroot $CHROOT_DIR umount /dev/pts
    chroot $CHROOT_DIR umount /sys
    chroot $CHROOT_DIR umount /proc

    umount $CHROOT_DIR/mnt
}

restart() {
    stop
    start
}

#######################################################################

update() {
    chroot $CHROOT_DIR apt-get update
}

upgrade() {
    chroot $CHROOT_DIR apt-get dist-upgrade
}

#######################################################################

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
    update)
        update
    ;;
    upgrade)
        upgrade
    ;;
    *)
        echo $"Usage: $0 {start|stop|restart|update|upgrade}"
        exit 1
esac

exit $?
