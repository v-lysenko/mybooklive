#!/bin/sh

CUSTOM="/DataVolume/custom"
C_ROOT="$CUSTOM/root"
C_OPT="$CUSTOM/opt"
C_VAR="$CUSTOM/var"

QUO="$CUSTOM/quo"

CHROOT_DIR='/var/opt/chroot'

#############################################

return_quo() {
echo 'Set up customizations =)'
cd /

## CURRENT magic
# Cleaning root
rm -rf /root/* > /dev/null
mkdir -p /root
cd /root

# Mounting custom dirs
if [ ! -d $C_ROOT ]; then
  mkdir -p $C_ROOT
fi
mount --bind $C_ROOT /root

if [ ! -d $C_OPT ]; then
  mkdir -p $C_OPT
fi
mount --bind $C_OPT /opt

if [ ! -d $C_VAR ]; then
  mkdir -p $C_VAR
fi
mount --bind $C_VAR /var/opt

#############################################

## APT magic
echo 'APT: holding udev, enabling lenny repos instead of squeeze'
aptitude hold udev > /dev/null
sed -ie "s/deb .* squeeze/#&/g" /etc/apt/sources.list
echo 'deb http://ftp.us.debian.org/debian/ lenny main' >> /etc/apt/sources.list
apt-cache clean > /dev/null

## HDD magic
echo 'HDD: fighting annoying parking'
. $QUO/bin/idle3ctl -d /dev/sda

#############################################

## MOUNT magic
script_mount

#############################################

## OPTWARE magic
if [ -z "$(ls /opt)" ]; then
  echo "OPTWARE: is not installed. You should fix it with [$0 optware]"
  OPTWARE='1'
else
  script_optware
  export PATH=$PATH:/opt/bin:/opt/sbin:/root/.bin
fi

#############################################

## CHROOT magic
if [ ! -d $CHROOT_DIR ]; then
  echo "CHROOT: dir is absent. You should fix it with [$0 chroot]"
  CHROOT='1'
elif [ -z "$(ls $CHROOT_DIR)" ]; then
  echo "CHROOT: is empty. You should fix it with [$0 chroot]"
  CHROOT='1'
else
  script_chroot
fi

#############################################

## ETC magic
if [ "$ZERO" != '1' ]; then
  . $QUO/bin/configs.sh
fi

#############################################

export PATH=$PATH:/root/.bin

echo 'Returning finished!'
echo 'Please REBOOT WD MyBook Live after you end ALL configurations!'
}

#######################################################################################
#######################################################################################

return_optware() {
  echo 'OPTWARE: installing...'
  OLD_CWD=$CWD
  cd /root
  . $QUO/bin/setup-mybooklive.sh > /dev/null
  cd $OLD_CWD

  script_optware
}

script_optware() {
  echo 'OPTWARE: enabling init scripts'
  cp $QUO/init.d/wedro_optware.sh /etc/init.d/wedro_optware.sh
  chmod a+x /etc/init.d/wedro_optware.sh
  update-rc.d wedro_optware.sh defaults 90 02 > /dev/null

  echo 'ETC: fixing PATH for optware use'
  echo 'export PATH=$PATH:/opt/bin:/opt/sbin' >> /etc/profile
}

#######################################################################################
#######################################################################################

return_chroot() {
  dpkg -i $QUO/deb/debootstrap_1.0.10lenny1_all.deb
  ln -s /usr/share/debootstrap/scripts/sid /usr/share/debootstrap/scripts/testing
  if [ -z "$(mount | grep '\/DataVolume\/custom\/var')" ]; then
    echo "CHROOT: custom /VAR was unmounted. Fixing..."
    mount --bind /DataVolume/custom/var /var/opt
  fi
  if [ ! -d $CHROOT_DIR ]; then
    echo "CHROOT: chroot dir was absent. Fixing..."
    mkdir -p $CHROOT_DIR
  fi
  debootstrap --variant=minbase --exclude=yaboot,udev,dbus --include=mc,aptitude --no-check-gpg testing $CHROOT_DIR http://ftp.ru.debian.org/debian/
  echo 'primary' > $CHROOT_DIR/etc/debian_chroot
  sed -i 's/^\(export PS1.*\)$/#\1/g' $CHROOT_DIR/root/.bashrc

  script_chroot
}

script_chroot() {
  echo 'CHROOT: enabling debian custom services in chroot'
  cp $QUO/init.d/wedro_chroot.sh /etc/init.d/wedro_chroot.sh
  chmod a+x /etc/init.d/wedro_chroot.sh
  update-rc.d wedro_chroot.sh defaults 99 01 > /dev/null
}

#######################################################################################
#######################################################################################

script_mount() {
  echo 'MOUNT: enabling necessary binded mounts at boot'
  cp $QUO/init.d/wedro_mount.sh /etc/init.d/wedro_mount.sh
  chmod a+x /etc/init.d/wedro_mount.sh
  update-rc.d wedro_mount.sh defaults 17 03 > /dev/null
}

#######################################################################################
#######################################################################################

update_packages() {
  apt-key adv --recv-keys --keyserver keyserver.ubuntu.com AED4B06F473041FA > /dev/null
  apt-get update
}

#######################################################################################
#######################################################################################

do_zero() {
#  check internet connection
  ZERO='1'
  return_quo
  if [ "$OPTWARE" == '1' ]; then
    return_optware
  fi
  if [ "$CHROOT" == '1' ]; then
    return_chroot
  fi
}

#######################################################################################
#######################################################################################

update_quo() {
  echo 'UPDATE: starting...'
  OLD_CWD=$CWD
  cd ..
  mv -f quo quo.old
  wget -r -l inf -R html -nH --cut-dirs=1 -P quo -nv -c http://mybooklive.googlecode.com/hg/
  chmod -v a+x quo/install.sh
  cd $OLD_CWD
  echo 'UPDATE: finished! You should inspect new scripts and run [renew] to install them'
}

update_scripts() {
  script_mount
  script_optware
  script_chroot
}

#######################################################################################
#######################################################################################
#######################################################################################

case "$1" in
    setup)
        return_quo
    ;;
    optware)
        return_optware
    ;;
    chroot)
        return_chroot
    ;;
    apt)
        update_packages
    ;;
    update)
        update_quo
    ;;
    renew)
        update_scripts
    ;;
    zero)
        do_zero
    ;;
    *)
        echo $"Usage: $0 {setup|optware*|chroot*|apt*|zero*|update*} (* - internet connection and completed [setup] section required)"
        echo "[setup] will set up scripts and configs & mount /opt, /root and /var/opt into /DataVolume"
        echo "[optware] will install Optware into /opt"
        echo "[chroot] will install Debian testing via debootstrap into $CHROOT_DIR"
        echo "[apt] will update packages in main system"
        echo "[zero] will do [setup], [optware] and [chroot]"
        echo "[update] will update QUO system =)"
        exit 1
esac

exit $?
