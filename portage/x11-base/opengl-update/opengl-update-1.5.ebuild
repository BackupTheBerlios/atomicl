# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /home/xubuntu/berlios_backup/github/tmp-cvs/atomicl/Repository/portage/x11-base/opengl-update/Attic/opengl-update-1.5.ebuild,v 1.1 2004/12/02 11:28:01 sjlongland Exp $

DESCRIPTION="Utility to change the OpenGL interface being used."
SRC_URI=""
HOMEPAGE="http://www.gentoo.org/"

KEYWORDS="x86 ppc sparc alpha hppa amd64 ia64 mips"
IUSE=""
SLOT="0"
LICENSE="GPL-2"

DEPEND="virtual/libc"


src_install() {
	newsbin ${FILESDIR}/opengl-update-${PV} opengl-update
}
