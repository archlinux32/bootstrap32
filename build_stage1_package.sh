#!/bin/sh

. "./default.conf"

# builds and installs one package for stage 1

if test "$(id -u)" = 0; then
	sudo -u cross "$0" "$1"
	exit 0
fi

PACKAGE=$1

# set PATH to use the proper cross-compiler binaries

export PATH="$XTOOLS_ARCH/bin:${PATH}"

# draw in default values for build variables

. "$SCRIPT_DIR/packages-$TARGET_CPU-stage1/template"

if test $(pacman --config "$STAGE1_CHROOT/etc/pacman.conf" -r "$STAGE1_CHROOT" -Q | cut -f 1 -d ' ' | grep -c "^${PACKAGE}$") = 0; then
	echo "Building package $PACKAGE."

	cd $STAGE1_BUILD || exit 1
	
	# clean up old build
	
	sudo rm -rf "$PACKAGE"
	rm -f $STAGE1_PACKAGES/$PACKAGE-*pkg.tar.xz

	# check out the package build information from the upstream git rep
	# using asp (or from the AUR using yaourt)
	
	PACKAGE_CONF="$SCRIPT_DIR/packages-$TARGET_CPU-stage1/$PACKAGE"	
	if test $(grep -c NEEDS_YAOURT $PACKAGE_CONF) = 1; then
		NEEDS_YAOURT=$(grep NEEDS_YAOURT $PACKAGE_CONF | cut -f 2 -d =)
	fi
	if test "$NEEDS_YAOURT"; then
		yaourt -G "$PACKAGE"
	else
		asp export "$PACKAGE"
	fi

	cd "$PACKAGE" || exit 1

	# attach our destination platform to be a supported architecture
	sed -i "/^arch=[^#]*any/!{/^arch=(/s/(/($TARGET_CPU /}" PKGBUILD

	# if there is a packages32 diff-PKGBUILD, attach it at the end
	# (we assume, we build only 'core' packages during stage1)
	DIFF_PKGBUILD="$ARCHLINUX32_PACKAGES/core/$PACKAGE/PKGBUILD"
	if test -f "$DIFF_PKGBUILD"; then
		cat "$DIFF_PKGBUILD" >> PKGBUILD
	fi

	# source package descriptions, sets variables for this script
	# and executes whatever is needed to build the package

	if test -f "$PACKAGE_CONF"; then
		. "$PACKAGE_CONF"
	fi
	
	# copy bigger patches into the build area
	if test $(find SCRIPT_DIR/patches-$TARGET_CPU-stage1/$PACKAGE-*.patch 2>/dev/null | grep -q .); then
		cp $SCRIPT_DIR/patches-$TARGET_CPU-stage1/$PACKAGE-*.patch .
	fi

	# disable or enable parallel builds
	
	if test "$NOPARALLEL_BUILD" = 0; then
		CPUS=$(nproc)
	else
		CPUS=1
	fi
	sed -i "s@^.*MAKEFLAGS=.*@MAKEFLAGS=\"-j$CPUS\"@" $STAGE1_BUILD/makepkg-$TARGET_CPU.conf

	# building the actual package
	
	$STAGE1_BUILD/makepkg-$TARGET_CPU -C --config $STAGE1_BUILD/makepkg-$TARGET_CPU.conf \
		--skipchecksums --skippgpcheck --nocheck > "$PACKAGE.log" 2>&1
	RES=$?
	
	tail "$PACKAGE.log"

	if test $RES = 0; then
	
		# copy to our package folder in the first stage chroot
		
		rm -f ./*debug*.pkg.tar.xz
		cp -v ./*.pkg.tar.xz $STAGE1_CHROOT/packages/$TARGET_CPU/.

		# redo the whole pacman cache and repo (always running into trouble
		# there, packages seem to reappear in old versions)
		
		rm -rf $STAGE1_CHROOT/var/cache/pacman/pkg/*
		rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db*
		rm -rf  $STAGE1_CHROOT/packages/$TARGET_CPU/temp.files*
		repo-add $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db.tar.gz $STAGE1_CHROOT/packages/$TARGET_CPU/*pkg.tar.xz
	
		# install into chroot via pacman
		
		sudo pacman --noconfirm --config "$STAGE1_CHROOT/etc/pacman.conf" -r "$STAGE1_CHROOT" -Syy "$PACKAGE"
		if test "x$ADDITIONAL_INSTALL_PACKAGE" != "x"; then
			sudo pacman --noconfirm --config "$STAGE1_CHROOT/etc/pacman.conf" -r "$STAGE1_CHROOT" -Syy "$ADDITIONAL_INSTALL_PACKAGE"
		fi

		# optionally install into cross-compiler sysroot with bsdtar
		
		if test "$SYSROOT_INSTALL" = 1; then
			cd "$XTOOLS_ARCH/$TARGET_CPU-unknown-linux-gnu/sysroot" || exit 1
			sudo bsdtar xvf $STAGE1_CHROOT/packages/$TARGET_CPU/$PACKAGE-*.pkg.tar.xz
			if test "x$ADDITIONAL_INSTALL_PACKAGE" != "x"; then
				sudo bsdtar xvf $STAGE1_CHROOT/packages/$TARGET_CPU/$ADDITIONAL_INSTALL_PACKAGE-*.pkg.tar.xz
			fi
			cd "$STAGE1_BUILD/$PACKAGE" || exit 1
		fi
		
	fi

	cd $STAGE1_BUILD || exit 1

fi

echo "Built package $PACKAGE."
