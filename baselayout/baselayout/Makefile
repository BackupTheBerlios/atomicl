ROOT=/
installdirs=bin boot dev etc home initrd lib mnt opt proc root sbin sys tmp usr var
bindirs=bin sbin etc/init.d

findopts=-not -regex CVS -not -name CVS -not -name .\*.swp

install:
	find $(installdirs) $(findopts) | cpio -pv $(ROOT)
	find $(installdirs) $(findopts) \
		-exec chown -v root:root "$(ROOT)/{}" \;
	find $(bindirs) $(findopts) \
		-exec chmod -v 755 "$(ROOT)/{}" \;
	find $(installdirs) $(findopts) -type d \
		-exec chmod -v 755 "$(ROOT)/{}" \;
	chmod -v 777 $(ROOT)/tmp
