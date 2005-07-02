#!/bin/ash

if [ -f /var/sys/.probed ]; then
	exit 0
fi

. /etc/prelinux.d/functions.sh

probe_module () {
	name=$( basename $1 .ko )
	
	echo -e "  Trying: $name...\033[K"
	
	if [ ! -f /var/sys/modules/${name} ]; then
		( modprobe ${name} ) 2>&1 >/dev/null
		echo $? > /var/sys/modules/${name}
	fi

	echo -en "\033[A\033[G\033[K"

	return $( cat /var/sys/modules/${name} )
}

probe_modules () {
	fail=0
	echo -en "\033[s"
	for module in $*; do
		echo -en "\033[u"
		if probe_module $module; then
			echo -n ''
		else
			fail=1
		fi
	done
	return $fail
}

modbase=/lib/modules/$( uname -r )

if [ ! -d $modbase ]; then
	# No modules... skip this step
	exit 0
fi

# Probe generic block devices
clear
ebegin "Probing generic block devices"
probe_modules $( find ${modbase}/kernel/drivers/block -name \*.ko )
eend $?

# Probe IDE devices
clear
ebegin "Probing IDE devices"
probe_modules $( find ${modbase}/kernel/drivers/ide -name \*.ko )
eend $?

# Probe SCSI devices
clear
ebegin "Probing SCSI devices"
probe_modules $( find ${modbase}/kernel/drivers/scsi -name \*.ko )
eend $?

# Probe network devices
clear
ebegin "Probing network devices"
probe_modules $( find ${modbase}/kernel/drivers/net -name \*.ko )
eend $?

# Probe USB host & storage
clear
ebegin "Probing USB devices"
probe_modules $( find ${modbase}/kernel/drivers/usb/host -name \*.ko ) \
	usbhid usb-storage
eend $?

# Probe PCMCIA
#clear
#ebegin "Probing PCMCIA"
#probe_modules $( find ${modules}/kernel/drivers/pcmcia -name \*.ko )
#eend $?
# TODO: Full PCMCIA support (need cardmgr)

clear

# Some functions for inspecting IDE and SCSI devices
inspect_ide () {
	device=${1}
	
	# What sort of device have we got?
	media=$( cat /proc/ide/${device}/media )

	case $media in
		disk)
			inspect_ide_disk ${device}
			;;
		cdrom)
			inspect_ide_cdrom ${device}
			;;
	esac
}

inspect_ide_disk () {
	device=${1}
	# Size, in blocks
	size=$( cat /sys/block/${device}/size )

	# Size, in MB
	size=$(( $size / 2048 ))
	einfo "  Found IDE Disk ${device}: ${size} MB"
	
	mkdir /var/sys/disks/${device}
	echo $size > /var/sys/disks/${device}/size
	ln -s /dev/${device} /var/sys/disks/${device}/device
}

inspect_ide_cdrom () {
	device=${1}
	einfo "  Found IDE CDROM ${device}"

	ln -s /dev/${device} /var/sys/cdroms/${device}
}

inspect_scsi_disk () {
	device=${1}

	# Size, in blocks
	size=$( cat /sys/block/${device}/size )

	# Size, in MB
	size=$(( $size / 2048 ))
	einfo "  Found SCSI Disk ${device}: ${size} MB"
	
	mkdir /var/sys/disks/${device}
	echo $size > /var/sys/disks/${device}/size
	ln -s /dev/${device} /var/sys/disks/${device}/device
}

inspect_scsi_cdrom () {
	device=${1}
	einfo "  Found SCSI CDROM ${device}"

	ln -s /dev/${device} /var/sys/cdroms/${device}
}

# Inspect what has been discovered.
ebegin "Looking for block devices"
for devicepath in /sys/block/*; do
	device=$( basename $devicepath )
	case $device in
		hd*)
			inspect_ide ${device}
			;;
		sd*)
			inspect_scsi_disk ${device}
			;;
#		fd[01])
#			inspect_floppy ${device}
#			;;
		sr*|scd*)
			inspect_scsi_cdrom ${device}
			;;
#		ram*)
#			inspect_ramdisk ${device}
#			;;
	esac
done

touch /var/sys/.probed
