# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /home/xubuntu/berlios_backup/github/tmp-cvs/atomicl/Repository/portage/sys-kernel/linux-headers/linux-headers-2.4.26-r1.ebuild,v 1.1 2005/07/23 02:20:26 sjlongland Exp $

ETYPE="headers"
H_SUPPORTEDARCH="arm m68k sparc"
inherit eutils kernel-2
detect_version

SRC_URI="${KERNEL_URI}"
KEYWORDS="-*"

UNIPATCH_LIST=""

src_unpack() {
	tc-arch-kernel
	kernel-2_src_unpack
}
