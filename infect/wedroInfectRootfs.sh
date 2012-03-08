#!/bin/sh

cp -f $(dirname $0)/wedroInfect* $1/usr/local/sbin
chmod a+x $1/usr/local/sbin/$(basename $0)
patch -b $1/usr/local/sbin/updateFirmwareFromFile.sh $1/usr/local/sbin/wedroInfectScript.patch

/DataVolume/quo/install.sh infect $1
