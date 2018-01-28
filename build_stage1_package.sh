#!/bin/sh

. "./default.conf"

# builds and installs one package for stage 1

if test "$(id -u)" = 0; then
	sudo -u cross "$0" "$1"
	exit 0
fi

PACKAGE=$1

export PATH="$XTOOLS_ARCH/bin:${PATH}"

NEEDS_YAOURT=0
NOPARALLEL_BUILD=0

if test ! -f "$STAGE1_CHROOT/packages/$TARGET_CPU/$PACKAGE.pkg.tar.xz"; then
	echo "Building package $PACKAGE."

	cd $STAGE1_BUILD || exit 1
	
	rm -rf "$PACKAGE"
	
	# source the package specific configuration
	
	PACKAGE_CONF="$SCRIPT_DIR/packages-$TARGET_CPU-stage1/$PACKAGE"
	if test -f "$PACKAGE_CONF"; then
		. "$PACKAGE_CONF"
	fi

	# get the package build description
	
	if test $NEEDS_YAOURT; then
		yaourt -G "$PACKAGE"
	else
		asp export "$PACKAGE"
	fi
	cd "$PACKAGE" || exit 1

	# if exists packages32 diff-PKGBUILD, attach at the end
	# (we assume, we build only 'core' packages)
	DIFF_PKGBUILD="$ARCHLINUX32_PACKAGES/core/$PACKAGE/PKGBUILD"
	if test -f "$DIFF_PKGBUILD"; then
		cat "$DIFF_PKGBUILD" >> PKGBUILD
	fi

	sed -i "/^arch=[^#]*any/!{/^arch=(/s/(/($TARGET_CPU /}" PKGBUILD

	if test $NOPARALLEL_BUILD = 0; then
		CPUS=$(nproc)
	else
		CPUS=1
	fi
	sed -i "s@^#MAKEFLAGS=.*@MAKEFLAGS=\"-j$CPUS\"@" $STAGE1_BUILD/makepkg-$TARGET_CPU.conf

	$STAGE1_BUILD/makepkg-$TARGET_CPU -C --config $STAGE1_BUILD/makepkg-$TARGET_CPU.conf \
		--skipchecksums --skippgpcheck --nocheck > "$PACKAGE.log" 2>&1
	RES=$?
	
	tail "$PACKAGE.log"

	if test $RES = 0; then
		rm -f ./*debug*.pkg.tar.xz
		cp -v ./*.pkg.tar.xz $STAGE1_CHROOT/packages/$TARGET_CPU/.
	fi
fi

echo "Built package $PACKAGE."
