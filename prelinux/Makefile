# PreLinux : Pre-boot Linux Distribution Initialisation Environment
#
# Stuart Longland <redhatter@gentoo.org>
# $Header: /home/xubuntu/berlios_backup/github/tmp-cvs/atomicl/Repository/prelinux/Makefile,v 1.4 2005/07/03 02:47:44 sjlongland Exp $
.PHONY:	all initramfs modules

# Config options
TARGET=i386-atomic-linux-uclibc
TYPE=bzImage
MAKEOPTS=
MAKEDEV=/usr/sbin/MAKEDEV

# Use SUDO for compiling busybox and making device nodes, etc.
# Comment out to disable
USE_SUDO=sudo

# Allow customisation of BusyBox:  Runs menuconfig so that you can
# fine tune compilation options.
CUSTOMISE_BUSYBOX=1

#------------------------------------------------------------------------------#

# What's considered a kernel?  For elf images, we just take the bare vmlinux
# file.  x86 systems normally use a bzImage, which is built differently.  Really
# old systems (e.g. early MIPS systems) used ECOFF images, which again, are
# built off the vmlinux file.
kernel=$(shell case "$(TYPE)" in ( elf ) k=vmlinux ;; ( ecoff )	k=vmlinux.ecoff ;; ( bzImage ) k=arch/i386/boot/bzImage ;; esac; echo $$k )

# Little shell script to extract the architecture type
arch=$(shell sh scripts/getarch $(TARGET) )

all:	prelinux

prelinux:	linux linux/$(kernel)
	cp linux/$(kernel) prelinux

xcc:	scripts/make_xcc
	TARGET=$(TARGET) sh scripts/make_xcc

root/init:	root/etc/prelinux.d/init.sh
	cd root ; ln -s etc/prelinux.d/init.sh init

root/.static/busybox:	scripts/make_busybox	xcc
	@echo make_busybox
	@TARGET=$(TARGET) \
		USE_SUDO=$(USE_SUDO) \
		CUSTOMISE_BUSYBOX=$(CUSTOMISE_BUSYBOX)\
			sh scripts/make_busybox

linux/arch/i386/boot/bzImage: initramfs linux/vmlinux
	$(MAKE) -C linux $(MAKEOPTS) bzImage CROSS_COMPILE=$(shell pwd)/xcc/

# Generating the vmlinux file... Note that we call `make vmlinux` twice here
# The first time is to generate the System.map file needed for producing the
# module dependancies.  This step is skipped if the linux/System.map file
# already exists.
linux/vmlinux: initramfs
	$(MAKE) -C linux $(MAKEOPTS) modules CROSS_COMPILE=$(shell pwd)/xcc/
	[ -f linux/System.map ] || $(MAKE) -C linux $(MAKEOPTS) vmlinux \
		CROSS_COMPILE=$(shell pwd)/xcc/
	$(MAKE) -C linux modules_install INSTALL_MOD_PATH=$(shell pwd)/initramfs
	$(MAKE) -C linux $(MAKEOPTS) vmlinux CROSS_COMPILE=$(shell pwd)/xcc/

initramfs/dev:
	mkdir -p initramfs/dev
	( cd initramfs/dev ; $(USE_SUDO) $(MAKEDEV) generic-$(arch) ) || \
		( rmdir initramfs/dev && exit 1 )
	$(USE_SUDO) chown -R $(UID) initramfs/dev

initramfs: root/.static/busybox root/init initramfs/dev
	( cd root ; find . | cpio -pv ../initramfs )
	( cd initramfs ; \
		ln -s .static bin ; \
		ln -s .static sbin ; \
		ln -s .static/busybox .static/ash \
	)

# User-provided files.
linux:
	@echo "ERROR: No Linux source tree present."
	@echo ''
	@echo "Unpack a source tree somewhere, configure it,"
	@echo "then symlink it here"
	@echo ''
	@echo "   ln -s /path/to/source/tree linux"
	@echo ''
	@echo "then run make again"
	@echo ''
	@echo "When configuring, make sure you set CONFIG_INITRAMFS_SOURCE"
	@echo "to $(PWD)/initramfs."
	@exit 1
