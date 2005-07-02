#!/bin/ash

. /etc/prelinux.d/functions.sh

einfo "Setting up the network"

if [ ! -f /var/sys/.probed ]; then
	sh /etc/prelinux.d/probe.sh
fi

# Function for setting up single ethernet device
setup () {
	device=$1

	if [ -f /var/sys/cmdline/$device ]; then
		config=$( cat /var/sys/cmdline/${device})
		ip=${config#/*}
		mask=${config%*/}

		if [ "$config" = "dhcp" ]; then
			ebegin "  Setting up ${device} via DHCP"
			ifconfig ${device} up
			udhcpc -b -i ${device}
			eend $?
		else
			ebegin "  Setting up ${device} via static config (${ip}/${mask}"
			ifconfig ${device} inet ${ip} netmask ${mask} up
			eend $?
		fi
	fi
}

for device in /sys/class/net/*; do
	device=${device##*/}
	case $device in
		eth*)
			setup ${device}
			;;
		lo)
			ebegin "  Setting up loopback device"
			ifconfig lo inet 127.0.0.1 netmask 255.0.0.0
			eend $?
			;;
	esac
done

if [ -f /var/sys/cmdline/routes ]; then
	for route in $( sed -e 's/,/ /g' /var/sys/cmdline/routes ); do
		dest=${route#>*}
		to=${route%*>}

		dtype=${dest#:*}
		daddr=${dest%*:}

		ttype=${to#:*}
		taddr=${to%*:}

		if [ "${ttype}" != "if" ]; then
			gateway="gw ${taddr}"
		fi
		
		ebegin "  Adding route ${dest} --> ${to}"
		route add -${dtype} ${daddr} ${gateway}
		eend $?
	done
fi

if [ -f /var/sys/cmdline/nameservers ]; then
	echo -n > /etc/resolv.conf
	
	for ns in $( sed -e 's/,/ /g' /var/sys/cmdline/nameservers ); do
		ebegin "  Adding nameserver $ns"
		echo "nameserver $ns" >> /etc/resolv.conf
		eend $?
	done
fi

einfo "Done setting up the network"

touch /var/sys/.net-up
