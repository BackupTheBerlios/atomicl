# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /home/xubuntu/berlios_backup/github/tmp-cvs/atomicl/Repository/portage/sys-kernel/linux-headers/linux-headers-2.6.8.1-r2.ebuild,v 1.1 2005/07/23 02:20:26 sjlongland Exp $

ETYPE="headers"
H_SUPPORTEDARCH="alpha amd64 arm hppa ia64 ppc ppc64 s390 sparc sh x86"
inherit kernel-2
detect_version

SRC_URI="${KERNEL_URI} mirror://gentoo/linux-2.6.8.1-sh-headers.patch.bz2"
KEYWORDS="x86"

UNIPATCH_LIST="${DISTDIR}/linux-2.6.8.1-sh-headers.patch.bz2
	${FILESDIR}/${PN}-2.6.0-sysctl_h-compat.patch
	${FILESDIR}/${PN}-2.6.0-fb.patch
	${FILESDIR}/${PN}-2.6.7-generic-arm-prepare.patch
	${FILESDIR}/${P}-strict-ansi-fix.patch
	${FILESDIR}/${P}-appCompat.patch
	${FILESDIR}/${PN}-soundcard-ppc64.patch
	${FILESDIR}/${P}-arm-float.patch
	${FILESDIR}/${P}-parisc-syscall.patch"

src_unpack() {
	kernel-2_src_unpack

	# Fixes ... all the mv magic is to keep sed from dumping 
	# ugly warnings about how it can't work on a directory.
	cd "${S}"/include
	mv asm-ia64/sn asm-ppc64/iSeries .
	headers___fix asm-ia64/*
	mv sn asm-ia64/
	headers___fix asm-ppc64/*
	mv iSeries asm-ppc64/
	headers___fix asm-ppc64/iSeries/*
	headers___fix linux/ethtool.h
}
