#!/bin/sh

# shellcheck source=./default.conf
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

. "$SCRIPT_DIR/$TARGET_CPU-stage1/template/DESCR"

if test "$(pacman --config "$STAGE1_CHROOT/etc/pacman.conf" -r "$STAGE1_CHROOT" -Q | cut -f 1 -d ' ' | grep -c "^${PACKAGE}$")" = 0 -o "$(find "$STAGE1_PACKAGES" -regex ".*/$PACKAGE-.*pkg\\.tar\\.xz" | grep -cv shim)" = 0; then
	echo "Building package $PACKAGE."
	
	cd $STAGE1_BUILD || exit 1
	
	# clean up old build
	
	sudo rm -rf "$PACKAGE"
	rm -f "$STAGE1_PACKAGES/$PACKAGE"-*pkg.tar.xz

	# check out the package build information from the upstream git rep
	# using asp (or from the AUR using yaourt)
	
	PACKAGE_DIR="$SCRIPT_DIR/$TARGET_CPU-stage1/$PACKAGE"
	PACKAGE_CONF="$PACKAGE_DIR/DESCR"	
	if test -f "$PACKAGE_CONF"; then
		if test "$(grep -c FETCH_METHOD "$PACKAGE_CONF")" = 1; then
			FETCH_METHOD=$(grep FETCH_METHOD "$PACKAGE_CONF" | cut -f 2 -d = | tr -d '"')
		fi
	fi
	case $FETCH_METHOD in
		"asp")
			$ASP export "$PACKAGE"
			;;
		"yaourt")
			yaourt -G "$PACKAGE"
			;;
		"packages32")
			# (we assume, we only take core packages)
			cp -a "$ARCHLINUX32_PACKAGES/core/$PACKAGE" .
			;;
		*)
			print "ERROR: unknown FETCH_METHOD '$FETCH_METHOD'.." >&2
			exit 1
	esac
			
	cd "$PACKAGE" || exit 1

	# attach our destination platform to be a supported architecture
	sed -i "/^arch=[^#]*any/!{/^arch=(/s/(/($TARGET_CPU /}" PKGBUILD

	# if there is a packages32 diff-PKGBUILD, attach it at the end
	# (we assume, we build only 'core' packages during stage1)
	DIFF_PKGBUILD="$ARCHLINUX32_PACKAGES/core/$PACKAGE/PKGBUILD"
	if test -f "$DIFF_PKGBUILD"; then
		cat "$DIFF_PKGBUILD" >> PKGBUILD
	fi

	# copy all other files from Archlinux32, if they exist
	# (we assume, we only take core packages during stage1)
	if test -f "$DIFF_PKGBUILD"; then
		find "$ARCHLINUX32_PACKAGES/core/$PACKAGE"/* ! -name PKGBUILD \
			-exec cp {} . \;
	fi
		
	# source package descriptions, sets variables for this script
	# and executes whatever is needed to build the package

	if test -f "$PACKAGE_CONF"; then
		. "$PACKAGE_CONF"
	fi
	
	# copy all files into the build area (but the package DESCR file)
	if test -d "$PACKAGE_DIR"; then
		find "$PACKAGE_DIR"/* ! -name DESCR \
			-exec cp {} . \;
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
		rm -rf $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db*
		rm -rf $STAGE1_CHROOT/packages/$TARGET_CPU/temp.files*
		repo-add $STAGE1_CHROOT/packages/$TARGET_CPU/temp.db.tar.gz $STAGE1_CHROOT/packages/$TARGET_CPU/*pkg.tar.xz
	
		# install into chroot via pacman
		
		if test "x$ADDITIONAL_INSTALL_PACKAGE" != "x"; then
			sudo pacman --noconfirm --config "$STAGE1_CHROOT/etc/pacman.conf" -r "$STAGE1_CHROOT" -Syy "$PACKAGE" "$ADDITIONAL_INSTALL_PACKAGE"
		else
			sudo pacman --noconfirm --config "$STAGE1_CHROOT/etc/pacman.conf" -r "$STAGE1_CHROOT" -Syy "$PACKAGE"
		fi

		# optionally install into cross-compiler sysroot with bsdtar
		
		if test "$SYSROOT_INSTALL" = 1; then
			cd "$XTOOLS_ARCH/$TARGET_CPU-unknown-linux-gnu/sysroot" || exit 1
			sudo bsdtar xf "$STAGE1_CHROOT/packages/$TARGET_CPU/$PACKAGE"-*.pkg.tar.xz
			if test "x$ADDITIONAL_INSTALL_PACKAGE" != "x"; then
				sudo bsdtar xf "$STAGE1_CHROOT/packages/$TARGET_CPU/$ADDITIONAL_INSTALL_PACKAGE"-*.pkg.tar.xz
			fi
			cd "$STAGE1_BUILD/$PACKAGE" || exit 1
		fi
		
		echo "Built package $PACKAGE."
	
	else	
		echo "ERROR building package $PACKAGE"
		exit 1
	fi

	cd $STAGE1_BUILD || exit 1

else
	echo "$PACKAGE exists."
fi

