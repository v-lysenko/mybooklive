#!/bin/sh
#
# � 2010 Western Digital Technologies, Inc. All rights reserved.
#
# createShare.sh <shareName> <shareDesc>
#

if [ -z "$1" ]; then
    echo "Enter share name! $0 <Name>"
    exit 1
elif [ -z "$2" ]; then
    echo "Enter share description! $0 $1 <Description>"
    exit 1
else
    /usr/local/sbin/saveUserShareState.sh
fi

#---------------------
# add stderr to stdout
exec 2>&1

PATH=/sbin:/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
. /usr/local/sbin/share-param.sh
. /usr/local/sbin/disk-param.sh

SYSTEM_SCRIPTS_LOG=${SYSTEM_SCRIPTS_LOG:-"/dev/null"}
# Output script log start info
{ 
echo "Start: `basename $0` `date`"
echo "Param: $@" 
} >> ${SYSTEM_SCRIPTS_LOG}
#
{
#---------------------
# Begin Script
#---------------------

shareName=$1
shareDesc=$2

# add share to trustees.conf
grep "/$shareName:" $trustees
if [ $? == 0 ]; then
  echo "Share $shareName already exists"
  exit 1
fi

# add to trustees
# check if symlink already added, this means that this is a removable drive
mnt_pt=`readlink /shares/${shareName}`
if [ "${mnt_pt}" != "" ]; then
	device=`mount | awk -v mntpt="$mnt_pt" '$0 ~ mntpt {print $1}'`
	# check if device is a valid parition block device before adding to trustees
	# if FUSE device, only add to samba, etc
	part_name=`basename $device`
	valid=`awk -v part_name="$part_name" '$0 ~ part_name {print "yes"}' /proc/partitions`
	if [ "$valid" == "yes" ]; then
		echo "#usb[$device]/shares/${shareName}:*:RWBEX:*:CU" >> $trustees
	else
		echo "#fuse[$device]/shares/${shareName}:*:RWBEX:*:CU" >> $trustees
	fi
else
	mkdir -p /shares/$shareName
	chgrp share /shares/$shareName 
	chmod 775 /shares/$shareName
	echo "[$dataVolumeDevice]/shares/${shareName}:*:ROBEX:*:CU" >> $trustees
fi

# add to samba overall_share, public share by default
echo "## BEGIN ## sharename = $shareName #" >> $sambaOverallShare
echo "[$shareName]" >> $sambaOverallShare
echo "  path = /shares/$shareName" >> $sambaOverallShare
echo "  comment = $shareDesc" >> $sambaOverallShare
echo "  public = yes" >> $sambaOverallShare
echo "  browseable = yes" >> $sambaOverallShare
echo "  writable = no" >> $sambaOverallShare
echo "  guest ok = yes" >> $sambaOverallShare
echo "  map read only = no" >> $sambaOverallShare
echo "## END ##" >> $sambaOverallShare


# reload
setTrustees.sh 2> /dev/null
/etc/init.d/samba reload > /dev/null

# add to AppleVolumes file
genAppleVolumes.sh

# add file tally folders
mkdir $fileTally/$shareName
echo "50" > $fileTally/$shareName/total_size
echo "10" > $fileTally/$shareName/photos_size
echo "10" > $fileTally/$shareName/music_size
echo "30" > $fileTally/$shareName/video_size

# regenerate apache share access rules
genApacheAccessRules.sh
apache2ctl -k graceful

#---------------------
# End Script
#---------------------
# Copy stdout to script log also
} | tee -a ${SYSTEM_SCRIPTS_LOG}
# Output script log end info
{ 
echo "End:$?: `basename $0` `date`" 
echo ""
} >> ${SYSTEM_SCRIPTS_LOG}

