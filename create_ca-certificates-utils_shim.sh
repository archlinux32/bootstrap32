#!/bin/sh

. "./default.conf"

# the ca-certificates-utils-shim shim

if test ! -f $STAGE1_CHROOT/packages/$TARGET_CPU/ca-certificates-utils-shim-20170307-1-any.pkg.tar.xz; then

	cd $STAGE1_BUILD || exit 1
	sudo rm -rf ca-certificates-utils-shim
	
	mkdir ca-certificates-utils-shim
	cd ca-certificates-utils-shim || exit 1
	mkdir -p pkg/ca-certificates-utils-shim/etc/ssl/certs/
	cp /etc/ssl/certs/ca-certificates.crt pkg/ca-certificates-utils-shim/etc/ssl/certs/.

	BUILDDATE=$(date '+%s')
	size=$(du -sk --apparent-size pkg/)
	size="$(( ${size%%[^0-9]*} * 1024 ))"
	cat > pkg/ca-certificates-utils-shim/.PKGINFO <<EOF
pkgname = ca-certificates-utils
pkgver = 20170307-1
pkgdesc = Common CA certificates (utilities, from host machine)
url = http://pkgs.fedoraproject.org/cgit/rpms/ca-certificates.git
builddate = $BUILDDATE
size = $size
arch = any
EOF

	cd pkg/ca-certificates-utils-shim || exit 1
	tar cJvf - .PKGINFO * | xz > ../../ca-certificates-utils-shim-20170307-1-any.pkg.tar.xz
	cd ../.. || exit 1

	cp -v ./*.pkg.tar.xz $STAGE1_CHROOT/packages/$TARGET_CPU/.
	rm -rf $STAGE1_CHROOT/var/cache/pacman/pkg/*
	rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db*
	rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.files*
	repo-add $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db.tar.gz $STAGE1_CHROOT/packages/$TARGET_CPU/*pkg.tar.xz
	sudo pacman --force --noconfirm --config $STAGE1_CHROOT/etc/pacman.conf -r $STAGE1_CHROOT -Syy ca-certificates-utils

fi

echo "ca-certificate shim exists."
