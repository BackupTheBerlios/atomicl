# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /home/xubuntu/berlios_backup/github/tmp-cvs/atomicl/Repository/portage/x11-libs/qt/Attic/qt-2.3.2-r1.ebuild,v 1.1 2004/12/02 11:28:13 sjlongland Exp $

DESCRIPTION="QT ${PV}, an X11 widget set and general library used by KDE et al"
HOMEPAGE="http://www.trolltech.com/"
SRC_URI="ftp://ftp.trolltech.com/pub/qt/source/qt-x11-${PV}.tar.gz"

LICENSE="|| ( QPL-1.0 GPL-2 )"
SLOT="2"
KEYWORDS="x86 ppc sparc hppa alpha amd64 ia64"
IUSE="gif opengl nas debug"

RDEPEND="virtual/x11
	media-libs/libpng
	media-libs/lcms
	>=media-libs/libmng-1.0.0
	>=media-libs/freetype-2
	gif? ( media-libs/giflib
		media-libs/libungif )
	nas? ( >=media-libs/nas-1.4.1 )
	opengl? ( virtual/opengl virtual/glu )"
DEPEND="${RDEPEND}
	sys-devel/gcc"

QTBASE=/usr/qt/2
export QTDIR=${S}

src_unpack() {
	unpack ${A}

	cd ${S}
	chmod +w configure
	cp configure configure.orig
	sed -e "s:read acceptance:acceptance=yes:" configure.orig > configure

	cd ${S}/configs
	cp linux-g++-shared linux-g++-shared.orig
	sed -e "s/SYSCONF_CXXFLAGS	/SYSCONF_CXXFLAGS = ${CXXFLAGS} \#/" \
	-e "s/SYSCONF_CFLAGS	/SYSCONF_CFLAGS = ${CFLAGS} \#/" \
	linux-g++-shared.orig > linux-g++-shared || die
}

src_compile() {
	export LDFLAGS="$LDFLAGS -ldl"
	local myconf

	use opengl || myconf="$myconf -no-opengl"
	use nas \
		&& myconf="${myconf} -system-nas-sound" \
		|| myconf="${myconf} -no-nas-sound"

	use gif	&& myconf="${myconf} -gif"

	use debug \
		&& myconf="${myconf} -debug" \
		|| myconf="${myconf} -release"

	./configure \
		-sm -thread -system-zlib -system-jpeg ${myconf} \
		-system-libmng -system-libpng -gif -platform linux-g++ \
		-ldl -lpthread -no-g++-exceptions -no-xft || die

	make symlinks src-moc sub-src sub-tools || die
}

src_install() {
	# binaries
	into $QTBASE
	dobin bin/*

	# libraries
	dolib lib/libqt.so.${PV} lib/libqt-mt.so.${PV} lib/libqutil.so.1.0.0
	cd ${D}$QTBASE/lib
	for x in libqt.so libqt-mt.so
	do
		ln -s $x.2.3.2 $x.2.3
		ln -s $x.2.3 $x.2
		ln -s $x.2 $x
	done
	ln -s libqutil.so.1.0.0 libqutil.so.1.0
	ln -s libqutil.so.1.0 libqutil.so.1
	ln -s libqutil.so.1 libqutil.so

	# includes
	cd ${S}
	dodir ${QTBASE}/include
	cp include/* ${D}/${QTBASE}/include/

	# misc
	insinto /etc/env.d
	doins ${FILESDIR}/{50qt2,45qtdir2}
}
