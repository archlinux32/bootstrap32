#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# prepare the i486-chroot for stage 1
# prepare pacman in i486-chroot

if test ! -d $STAGE1_CHROOT; then

	# create and initialize a new i486 chroot in $STAGE1_CHROOT
	
	echo "Creating chroot for stage 1 artifacts in $STAGE1_CHROOT"
	mkdir $STAGE1_CHROOT

	# prepare directories for a new pacman root
	
	mkdir -p $STAGE1_CHROOT/etc/pacman.d $STAGE1_CHROOT/var/lib/pacman \
		$STAGE1_CHROOT/var/cache/pacman/pkg \
		$STAGE1_CHROOT/var/log $STAGE1_CHROOT/etc/pacman.d/gnupg/ \
		$STAGE1_CHROOT/etc/pacman.d/hooks/

	# adapt configuration to work from outside the chroot to write artifacts
	# into the chroot

	cp /etc/pacman.conf $STAGE1_CHROOT/etc/.
	
	sed -i '/\[archlinuxfr\]/,// d' $STAGE1_CHROOT/etc/pacman.conf
	sed -i '/\[multilib\]/,// d' $STAGE1_CHROOT/etc/pacman.conf

	sed -i 's@^Architecture.*@Architecture = i486@g' $STAGE1_CHROOT/etc/pacman.conf

	sed -i 's@#RootDir.*@RootDir = /home/cross/i486-root@g' $STAGE1_CHROOT/etc/pacman.conf
	sed -i 's@#DBPath.*@DBPath = /home/cross/i486-root/var/lib/pacman/@g' $STAGE1_CHROOT/etc/pacman.conf
	sed -i 's@#CacheDir.*@CacheDir = /home/cross/i486-root/var/cache/pacman/pkg/@g' $STAGE1_CHROOT/etc/pacman.conf
	sed -i 's@#LogFile.*@LogFile = /home/cross/i486-root/var/log/pacman.log@g' $STAGE1_CHROOT/etc/pacman.conf
	sed -i 's@#GPGDir.*@GPGDir = /home/cross/i486-root/etc/pacman.d/gnupg/@g' $STAGE1_CHROOT/etc/pacman.conf
	sed -i 's@#HookDir.*@HookDir = /home/cross/i486-root/etc/pacman.d/hooks/@g' $STAGE1_CHROOT/etc/pacman.conf
	sed -i 's@^HoldPkg@#HoldPkg@g' $STAGE1_CHROOT/etc/pacman.conf

	# disable all standard repos

	sed -i 's@\(^Include = /etc/pacman.d/mirrorlist\)@#\1@g' $STAGE1_CHROOT/etc/pacman.conf
	sed -i 's@\[core\]@#[core]@g' $STAGE1_CHROOT/etc/pacman.conf
	sed -i 's@\[extra\]@#[extra]@g' $STAGE1_CHROOT/etc/pacman.conf
	sed -i 's@\[community\]@#[community]@g' $STAGE1_CHROOT/etc/pacman.conf

	# add a temporary package repo in the filesystem
	cat >>$STAGE1_CHROOT/etc/pacman.conf <<EOF
[temp]
SigLevel = Never
Server = file://$STAGE1_CHROOT/packages/\$arch
EOF

	# create a local package directory

	mkdir -p $STAGE1_CHROOT/packages $STAGE1_CHROOT/packages/i486
	repo-add -n $STAGE1_CHROOT/packages/i486/temp.db.tar.gz $STAGE1_CHROOT/packages/i486/*

	# finally, test and initialize ALPM library

	sudo pacman --config $STAGE1_CHROOT/etc/pacman.conf -r $STAGE1_CHROOT -Syyu
	pacman --config $STAGE1_CHROOT/etc/pacman.conf -r $STAGE1_CHROOT -Q
fi

if test ! -d $STAGE1_BUILD; then

	# prepare the build enviroment
	
	mkdir $STAGE1_BUILD
	cd $STAGE1_BUILD || exit 1

	# prepare makepkg for building into the i486-chroot
	cp /usr/bin/makepkg $STAGE1_BUILD/makepkg-i486

	# patch run_pacman in makepkg, we cannot pass the pacman root to it as parameter ATM
	
	sed -i "s@\"\$PACMAN_PATH\"@\"\$PACMAN_PATH\" --config $STAGE1_CHROOT/etc/pacman.conf -r $STAGE1_CHROOT@" makepkg-i486

	# prepare a configuration for building the packages with makepkg
	# fitting to the destination architecture
	
	cp /etc/makepkg.conf makepkg-i486.conf
	sed -i "s@^CARCH=.*@CARCH=\"i486\"@" makepkg-i486.conf
	sed -i "s@^CHOST=.*@CHOST=\"${TARGET_ARCH}\"@" makepkg-i486.conf
	CPUS=$(nproc)
	sed -i "s@^#MAKEFLAGS=.*@MAKEFLAGS=\"-j$CPUS\"@" makepkg-i486.conf
	sed -i "s@-march=x86-64 -mtune=generic @@" makepkg-i486.conf
	sed -i "s@-march=i686 -mtune=generic @@" makepkg-i486.conf

	echo "Prepared the stage 1 build environment."
fi

if test ! -d $CROSS_HOME/packages32; then
	
	# get packages repo from Archlinux32 for the diffs

	git clone $GIT_URL_ARCHLINUX32_PACKAGES $CROSS_HOME/packages32
	
	echo "Fetched Archlinux32 diffs for packages."
fi

echo "Stage 1 repos ready."
