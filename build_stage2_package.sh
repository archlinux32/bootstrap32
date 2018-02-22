#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# builds and installs one package for stage 1

if test "$(id -u)" = 0; then
	sudo -u cross "$0" "$1"
	exit 0
fi

PACKAGE=$1

# draw in default values for build variables

. "$SCRIPT_DIR/$TARGET_CPU-stage2/template/DESCR"

if test "$(find "$STAGE2_PACKAGES" -regex ".*/$PACKAGE-.*pkg\\.tar\\.xz" | wc -l)" = 0; then
	echo "Building package $PACKAGE."
		
	cd $STAGE2_BUILD || exit 1
	
	# clean up old build
	
	sudo rm -rf "$PACKAGE"
	rm -f "$STAGE2_PACKAGES/$PACKAGE"-*pkg.tar.xz
	ssh -i $CROSS_HOME/.ssh/id_rsa root@$STAGE1_MACHINE_IP rm -rf "/build/$PACKAGE"

	# check out the package build information from the upstream git rep
	# using asp (or from the AUR using yaourt)
	
	PACKAGE_DIR="$SCRIPT_DIR/$TARGET_CPU-stage2/$PACKAGE"
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

	# copy all files into the build area on the target machine 
	# (but the package DESCR file)
	if test -d "$PACKAGE_DIR"; then
		find "$PACKAGE_DIR"/* ! -name DESCR \
			-exec cp {} . \;
	fi
	
	# execute makepkg on the host, we don't have git on the stage 1 machine (yet)
	makepkg --nobuild

	# copy everything to the stage 1 machine
	scp -i $CROSS_HOME/.ssh/id_rsa -rC "$STAGE2_BUILD/$PACKAGE" build@$STAGE1_MACHINE_IP:/build/.

	# building the actual package
	ssh -i $CROSS_HOME/.ssh/id_rsa build@$STAGE1_MACHINE_IP bash -c "'cd $PACKAGE && makepkg --skipchecksums --skippgpcheck --nocheck'" > $PACKAGE.log 2>&1
	RES=$?
	
	tail "$PACKAGE.log"

	if test $RES = 0; then

		# copy to our package folder in the first stage chroot
		
		ssh -i $CROSS_HOME/.ssh/id_rsa root@$STAGE1_MACHINE_IP bash -c "'
			cd /build/$PACKAGE
			rm -f ./*debug*.pkg.tar.xz
			cp -v ./*.pkg.tar.xz /packages/$TARGET_CPU/.
		'"

		# redo the whole pacman cache and repo (always running into trouble
		# there, packages seem to reappear in old versions)

		ssh -i $CROSS_HOME/.ssh/id_rsa root@$STAGE1_MACHINE_IP bash -c "'
			rm -rf /var/cache/pacman/pkg/*
			rm -rf /packages/$TARGET_CPU/temp.db*
			rm -rf /packages/$TARGET_CPU/temp.files*
			repo-add /packages/$TARGET_CPU/temp.db.tar.gz /packages/$TARGET_CPU/*pkg.tar.xz
		'"
		
		# install onto stage 1 system via pacman

		ssh -i $CROSS_HOME/.ssh/id_rsa root@$STAGE1_MACHINE_IP bash -c "'		
			# TODO: broken [temp] repo
			#pacman --noconfirm -Syy $PACKAGE
			pacman --noconfirm -U /packages/$TARGET_CPU/$PACKAGE-*.pkg.tar.xz
			if test $ADDITIONAL_INSTALL_PACKAGE != ""; then
				#pacman --noconfirm -Syy $ADDITIONAL_INSTALL_PACKAGE
				pacman --noconfirm -U /packages/$TARGET_CPU/$ADDITIONAL_INSTALL_PACKAGE-*.pkg.tar.xz
			fi		
		'"
		
		# copy packages from target machine and replace our local version with it

		tmp_dir=$(mktemp -d 'tmp.compute-dependencies.0.XXXXXXXXXX' --tmpdir)
		trap 'rm -rf --one-file-system "${tmp_dir}"' EXIT
		
		mv "$STAGE2_BUILD/$PACKAGE/$PACKAGE.log" "$tmp_dir"
		cd "$STAGE2_BUILD" || exit 1
		rm -rf "$PACKAGE"
		scp -i $CROSS_HOME/.ssh/id_rsa -rC build@$STAGE1_MACHINE_IP:/build/"$PACKAGE" "$STAGE2_BUILD/."
		mv "$tmp_dir/$PACKAGE.log" "$STAGE2_BUILD/$PACKAGE/."
		mv -vf "$STAGE2_BUILD/$PACKAGE/"*.pkg.tar.xz "$STAGE2_PACKAGES/."

		echo "Built package $PACKAGE."
		
	else	
		echo "ERROR building package $PACKAGE"
		exit 1
	fi

	cd $STAGE2_BUILD || exit 1

else
	echo "$PACKAGE exists."
fi
