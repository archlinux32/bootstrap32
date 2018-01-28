#!/bin/sh

. "./default.conf"

# builds and installs one package for stage 1

if test "$(id -u)" = 0; then
	sudo -u cross "$0" "$1"
	exit 0
fi

PACKAGE=$1

export PATH="$XTOOLS_ARCH/bin:${PATH}"

. "$SCRIPT_DIR/packages-$TARGET_CPU-stage1/template"

if test $(pacman --noconfirm --config "$STAGE1_CHROOT/etc/pacman.conf" -r "$STAGE1_CHROOT" -Q | grep -c "$PACKAGE") = 0; then
	echo "Building package $PACKAGE."

	cd $STAGE1_BUILD || exit 1
	
	rm -rf "$PACKAGE"
	
	# source the package specific configuration
	
	PACKAGE_CONF="$SCRIPT_DIR/packages-$TARGET_CPU-stage1/$PACKAGE"
	if test -f "$PACKAGE_CONF"; then
		. "$PACKAGE_CONF"
	fi

	# get the package build description
	
	if test "$NEEDS_YAOURT"; then
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

	if test "$NOPARALLEL_BUILD" = 0; then
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

		# redo the whole cache
		rm -rf $STAGE1_CHROOT/var/cache/pacman/pkg/*
		rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db*
		rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.files*
		repo-add $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db.tar.gz $STAGE1_CHROOT/packages/$TARGET_CPU/*pkg.tar.xz
	
		# for util-linux also libutil-linux
		sudo pacman --noconfirm --config "$STAGE1_CHROOT/etc/pacman.conf" -r "$STAGE1_CHROOT" -Syy "$PACKAGE"
		pacman --noconfirm --config "$STAGE1_CHROOT/etc/pacman.conf" -r "$STAGE1_CHROOT" -Q

		if test "$SYSROOT_INSTALL" = 1; then
			cd "$XTOOLS_ARCH/$TARGET_CPU-unknown-linux-gnu/sysroot" || exit 1
			sudo bsdtar xvf "$STAGE1_CHROOT/packages/$TARGET_CPU/$PACKAGE-*.pkg.tar.xz"
			cd "$STAGE1_BUILD/$PACKAGE" || exit 1
		fi
		
	fi

	cd $STAGE1_BUILD || exit 1

fi

echo "Built package $PACKAGE."
