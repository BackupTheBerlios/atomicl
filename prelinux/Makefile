.PHONY:	all initramfs modules

# Config options
TYPE=bzImage
MAKEOPTS=
MAKEDEV=/usr/sbin/MAKEDEV

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
	sh scripts/make_xcc

root/bin/busybox:	scripts/make_busybox	xcc
	sh scripts/make_busybox

linux/arch/i386/boot/bzImage: initramfs
	$(MAKE) -C linux $(MAKEOPTS) bzImage CROSS_COMPILE=$(shell pwd)/xcc/

linux/vmlinux: initramfs
	$(MAKE) -C linux $(MAKEOPTS) vmlinux CROSS_COMPILE=$(shell pwd)/xcc/

# Produce a System.map file... Needed for module dependancies.
linux/System.map:
	$(MAKE) -C linux $(MAKEOPTS) vmlinux CROSS_COMPILE=$(shell pwd)/xcc/
	rm linux/vmlinux

initramfs/lib/modules:	linux/System.map 
	$(MAKE) -C linux $(MAKEOPTS) modules CROSS_COMPILE=$(shell pwd)/xcc/
	$(MAKE) -C linux modules_install INSTALL_MOD_PATH=$(shell pwd)/initramfs

initramfs/dev:
	mkdir initramfs/dev
	( cd initramfs/dev ; $(MAKEDEV) generic-$(arch) ) || \
		( rmdir initramfs/dev && exit 1 )

initramfs: root/bin/busybox initramfs/lib/modules linux/System.map initramfs/dev
	( cd root ; find . | cpio -pv ../initramfs )

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
