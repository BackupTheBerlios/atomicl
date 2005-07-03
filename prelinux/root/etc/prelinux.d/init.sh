#!/bin/ash

. /etc/prelinux.d/functions.sh

sleep 1
clear
cat /etc/prelinux.d/banner
sleep 2
einfo "PreLinux v0.0.1: Pre-boot Linux Distribution Initialisation Environment"
einfo "          (C) 2005 Atomic Linux Project & Gentoo Foundation"
einfo "      Distributed under the terms of the GNU PUBLIC LICENCE v2.0"
echo ''
einfo "Preparing to start Linux"
sleep 1

ebegin "Mounting /proc"
mount proc /proc -t proc
eend $?

ebegin "Mounting /sys"
mount none /sys -t sysfs
eend $?

ebegin "Mounting /tmp"
mount none /tmp -t tmpfs
eend $?

load_kparams

/etc/prelinux.d/probe.sh

if [ -f /var/sys/cmdline/setup ]; then
        einfo "Running setup script"
        script="$( cat /var/sys/cmdline/setup )"

        fetch /tmp "${script}"
	if [ -f /tmp/${script##*/} ]; then
        	exec ash /tmp/${script##*/}
	else
		eerror "Failed to download setup script ${script}"
		eerror "This shouldn't happen.  Dropping you to a shell."
		eerror "Type \`exec $0\` to try again."
		exec ash
	fi
fi

if [ -f /var/sys/cmdline/noinit ]; then
	einfo "Dropping you to a bare shell without init."
	einfo "If you want more shells, try \`exec /sbin/init\`."
	exec ash --login -i
fi

einfo "No setup commandline option given.  Starting up in stand-alone mode"
exec init
