#!/bin/sh

. "./default.conf"

# the gcc-lib shim

if test ! -f $STAGE1_CHROOT/packages/$TARGET_CPU/gcc-libs-shim-7.2.0-1-$TARGET_CPU.pkg.tar.xz; then

	cd $STAGE1_BUILD
	rm -rf gcc-libs-shim
	mkdir gcc-libs-shim
	cd gcc-libs-shim
	mkdir -p pkg/gcc-libs-shim/usr/lib
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libgcc_s.so pkg/gcc-libs-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libgcc_s.so.1 pkg/gcc-libs-shim/usr/lib/.
	cp -L $XTOOLS_ARCH/$TARGET_ARCH/lib/libatomic.so.1.2.0 pkg/gcc-libs-shim/usr/lib/.
	ln -s libatomic.so.1.2.0 pkg/gcc-libs-shim/usr/lib/libatomic.so.1
	ln -s libatomic.so.1.2.0 pkg/gcc-libs-shim/usr/lib/libatomic.so
	cp -L $XTOOLS_ARCH/$TARGET_ARCH/lib/libatomic.a pkg/gcc-libs-shim/usr/lib/.
	cp -L $XTOOLS_ARCH/$TARGET_ARCH/lib/libstdc++.so.6.0.24 pkg/gcc-libs-shim/usr/lib/.
	ln -s libstdc++.so.6.0.24 pkg/gcc-libs-shim/usr/lib/libstdc++.so.6
	ln -s libstdc++.so.6.0.24 pkg/gcc-libs-shim/usr/lib/libstdc++.so

	BUILDDATE=`date '+%s'`
	size=`du -sk --apparent-size pkg/`
	size="$(( ${size%%[^0-9]*} * 1024 ))"
	cat > pkg/gcc-libs-shim/.PKGINFO <<EOF
pkgname = gcc-libs-shim
pkgver = 4.9.4-1
pkgdesc = Runtime libraries shipped by GCC (from crosstool-ng sysroot)
url = http://gcc.gnu.org
builddate = $BUILDDATE
size = $size
arch = $TARGET_CPU
provides = gcc-libs
conflict = gcc-libs
EOF

	cd pkg/gcc-libs-shim
	tar cJvf - .PKGINFO * | xz > ../../gcc-libs-shim-7.2.0-1-$TARGET_CPU.pkg.tar.xz
	cd ../..

	cp -v *.pkg.tar.xz $STAGE1_CHROOT/packages/$TARGET_CPU/.
	rm -rf $STAGE1_CHROOT/var/cache/pacman/pkg/*
	rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db*
	rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.files*
	repo-add -R $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db.tar.gz $STAGE1_CHROOT/packages/$TARGET_CPU/*pkg.tar.xz
	sudo pacman --noconfirm --config $STAGE1_CHROOT/etc/pacman.conf -r $STAGE1_CHROOT -Syy gcc-libs-shim
fi

echo "gcc-lib shim exists."
