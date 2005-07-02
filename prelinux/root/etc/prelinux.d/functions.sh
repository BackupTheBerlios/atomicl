# Copyright 2005 Atomic Linux Team
# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: /home/xubuntu/berlios_backup/github/tmp-cvs/atomicl/Repository/prelinux/root/etc/prelinux.d/functions.sh,v 1.1 2005/07/02 01:46:50 sjlongland Exp $

# Colours:
GOOD="\033[32;1m"
WARN="\033[33;1m"
BAD="\033[31;1m"
BRACKET="\033[36;1m"
NORMAL="\033[0m"

# Terminal Information:
ROWS=$( stty -a | grep rows | sed -e 's/^.*rows \([^;]*\);.*$/\1/' )
COLUMNS=$( stty -a | grep columns | sed -e 's/^.*columns \([^;]*\);.*$/\1/' )

# Positions
#  for the [ xx ] indicators
ENDCOL="\033[A\033["$(( $COLUMNS - 7 ))'G'

# void einfo(char* message)
#
#    show an informative message (with a newline)
#
einfo() {
	if [ "${RC_QUIET_STDOUT}" != "yes" ]
	then
		echo -e " ${GOOD}*${NORMAL} ${*}"
	fi

	return 0
}

# void einfon(char* message)
#
#    show an informative message (without a newline)
#
einfon() {
	if [ "${RC_QUIET_STDOUT}" != "yes" ]
	then
		echo -ne " ${GOOD}*${NORMAL} ${*}"
	fi

	return 0
}

# void ewarn(char* message)
#
#    show a warning message + log it
#
ewarn() {
	if [ "${RC_QUIET_STDOUT}" = "yes" ]
	then
		echo " ${*}"
	else
		echo -e " ${WARN}*${NORMAL} ${*}"
	fi

	return 0
}

# void eerror(char* message)
#
#    show an error message + log it
#
eerror() {
	if [ "${RC_QUIET_STDOUT}" = "yes" ]
	then
		echo " ${*}" >/dev/stderr
	else
		echo -e " ${BAD}*${NORMAL} ${*}"
	fi

	return 0
}

# void ebegin(char* message)
#
#    show a message indicating the start of a process
#
ebegin() {
	if [ "${RC_QUIET_STDOUT}" != "yes" ]
	then
		if [ "${RC_NOCOLOR}" = "yes" ]
		then
			echo -ne " ${GOOD}*${NORMAL} ${*}..."
		else
			echo -e " ${GOOD}*${NORMAL} ${*}..."
		fi
	fi

	return 0
}

# void eend(int error, char* errstr)
#
#    indicate the completion of process
#    if error, show errstr via eerror
#
eend() {
	local retval=
	
	if [ "$#" -eq 0 ] || ([ -n "$1" ] && [ "$1" -eq 0 ])
	then
		if [ "${RC_QUIET_STDOUT}" != "yes" ]
		then
			echo -e "${ENDCOL}  ${BRACKET}[ ${GOOD}ok${BRACKET} ]${NORMAL}"
		fi
	else
		retval="$1"
		
		if [ "$#" -ge 2 ]
		then
			shift
			eerror "${*}"
		fi
		if [ "${RC_QUIET_STDOUT}" != "yes" ]
		then
			echo -e "${ENDCOL}  ${BRACKET}[ ${BAD}!!${BRACKET} ]${NORMAL}"
			# extra spacing makes it easier to read
			echo
		fi
		return ${retval}
	fi

	return 0
}

# void ewend(int error, char *warnstr)
#
#    indicate the completion of process
#    if error, show warnstr via ewarn
#
ewend() {
	local retval=
	
	if [ "$#" -eq 0 ] || ([ -n "$1" ] && [ "$1" -eq 0 ])
	then
		if [ "${RC_QUIET_STDOUT}" != "yes" ]
		then
			echo -e "${ENDCOL}  ${BRACKET}[ ${GOOD}ok${BRACKET} ]${NORMAL}"
		fi
	else
		retval="$1"
		if [ "$#" -ge 2 ]
		then
			shift
			ewarn "${*}"
		fi
		if [ "${RC_QUIET_STDOUT}" != "yes" ]
		then
			echo -e "${ENDCOL}  ${BRACKET}[ ${WARN}!!${BRACKET} ]${NORMAL}"
			# extra spacing makes it easier to read
			echo
		fi
		return "${retval}"
	fi

	return 0
}

# int load_kparams ()
#
#	Parse the kernel command line, storing results in /var/sys/cmdline
#
#	Returns:
#		0 on success
#		1 if /proc/cmdline is missing
# 		2 if /var/sys/cmdline is missing
load_kparams() {
	[ -f /proc/cmdline ] || return 1
	[ -d /var/sys/cmdline ] || return 2

	for argument in $( cat /proc/cmdline ); do
		# Split it up...
		variable=${argument%=*}
		value=${argument#*=}
		
		# Is this an argument=value type argument?  Or just an argument?
		# variable, value and argument will be identical in this case.
		if [ "$argument" = "$variable" -a "$variable" = "$value" ]; then
			touch /var/sys/cmdline/${argument}
		else
			echo "$value" > /var/sys/cmdline/${variable}
		fi
	done
	return 0
}

# void fetch ( string destination_directory, string[] urls ... )
#
#	Download (or symlink) files to a given directory.
#
fetch () {
	local dest="$1"
	shift 1
	
	for url in $*; do
		case "${url%:*}" in
			http|https|ftp)
				if [ ! -f /var/sys/.net-up ]; then
					sh /etc/prelinux.d/init-net.sh
				fi
				ebegin "Downloading ${url}"
				wget -P "${dest}" "${url}"
				eend $?
				;;
			cdrom)
				# Note, that /var/sys/cd is only mounted when we know
				# the right CD is loaded.  Until then, we make sure the
				# directory does not exist.
				if [ ! -d /var/sys/cd ]; then
					find_cd "${url#*}"
				fi
				ln -s "/var/sys/cd/${url#*:}" "${dest}"
				;;
			*)
				eerror "Unknown protocol.  Don't know how to access ${url}"
				;;
		esac
	done
}

# bool find_cd ( string file [string contentType string content] )
#
#	Find a file on a CD.  This is largely for detecting that we have the right CD.
#	Valid "content type" strings are:
#
#		text	Look for a file with this content (uses grep)
#		sha1	Look for a file with this SHA1sum
#		md5	Look for a file with this MD5sum
#		file	Look for a file with this `file` output
#
#	If omitted, does a test -e $file instead.
#
#	If the specified file is located on a CD, it is left mounted on /var/sys/cd
#	Else, it exits with nonzero status.

find_cd () {
	file="${1}"
	type=${2}
	content="${3}"

	mkdir /var/sys/cd
	for cdrom in /var/sys/cdroms/*; do
		mount $cdrom /var/sys/cd
		case "${type}" in
			text)
				grep -q "${content}" "/var/sys/cd${file}" 
				status=$?
				;;
			sha1|md5)
				echo "/var/sys/cd${file}  ${content}" > /tmp/checksum
				${type}sum --status -c /tmp/checksum
				status=$?
				rm /tmp/checksum
				;;
			file)
				test "$( file -b "/var/sys/cd${file}" )" = "${content}"
				status=$?
				;;
			*)
				test -f /var/sys/cd${file}
				status=$?
				;;
		esac
		if [ $status = 0 ]; then
			return 0
		fi
		umount /var/sys/cd
	done
	rmdir /var/sys/cd
	return 1
}
# vim:ts=4
