#!/bin/sh

. "./default.conf"

# the glibc-shim shim

if test ! -f $STAGE1_CHROOT/packages/$TARGET_CPU/glibc-shim-2.26-1-$TARGET_CPU.pkg.tar.xz; then

	cd $STAGE1_BUILD
	rm -rf glibc-shim
	mkdir glibc-shim
	cd glibc-shim
	mkdir -p pkg/glibc-shim/usr/include
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/include/* pkg/glibc-shim/usr/include
	sudo rm -rf pkg/glibc-shim/usr/include/{linux,misc,mtd,rdma,scsi,sound,video,xen,asm,asm-generic}
	mkdir -p pkg/glibc-shim/etc
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/etc/rpc pkg/glibc-shim/etc/.
	mkdir -p pkg/glibc-shim/usr/bin
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/bin/* pkg/glibc-shim/usr/bin/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/sbin/* pkg/glibc-shim/usr/bin/.
	mkdir -p pkg/glibc-shim/usr/lib
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/lib/*.o pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/lib/*.a pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/lib/*.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/ld-linux.so.2 pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/ld-2.26.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libc.so.6 pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libc-2.26.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libpthread.so.0 pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libpthread-2.26.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/lib/gconv pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libutil.so* pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libutil-2.26.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libanl.so.1 pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libanl-2.26.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libBrokenLocale.so.1 pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libBrokenLocale-2.26.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libcrypt.so.1 pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libcrypt-2.26.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libdl.so.2 pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libdl-2.26.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libm.so.6 pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libm-2.26.so pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libnsl* pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libnss* pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libresolv* pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/librt* pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/lib/libthread_db* pkg/glibc-shim/usr/lib/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/lib/audit pkg/glibc-shim/usr/lib/.
	mkdir -p pkg/glibc-shim/usr/share
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/share/i18n pkg/glibc-shim/usr/share/.
	cp -a $XTOOLS_ARCH/$TARGET_ARCH/sysroot/usr/share/locale pkg/glibc-shim/usr/share/.

	BUILDDATE=`date '+%s'`
	size=`du -sk --apparent-size pkg/`
	size="$(( ${size%%[^0-9]*} * 1024 ))"
	cat > pkg/glibc-shim/.PKGINFO <<EOF
pkgname = glibc-shim
pkgver = 2.26-1
pkgdesc = GNU C Library (from crosstool-ng sysroot)
url = http://www.gnu.org/software/libc
builddate = $BUILDDATE
size = $size
arch = $TARGET_CPU
provides = glibc
conflict = glibc
EOF

	cd pkg/glibc-shim
	tar cJvf - .PKGINFO * | xz > ../../glibc-shim-2.26-1-$TARGET_CPU.pkg.tar.xz
	cd ../..

	cp -v *.pkg.tar.xz $STAGE1_CHROOT/packages/$TARGET_CPU/.
	rm -rf $STAGE1_CHROOT/var/cache/pacman/pkg/*
	rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db*
	rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.files*
	repo-add $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db.tar.gz $STAGE1_CHROOT/packages/$TARGET_CPU/*pkg.tar.xz
	sudo pacman --force --noconfirm --config $STAGE1_CHROOT/etc/pacman.conf -r $STAGE1_CHROOT -Syy glibc-shim

fi

echo "glibc shim exists."
