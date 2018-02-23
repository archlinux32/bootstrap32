#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# prepare the i486-build for stage 2

if test ! -d $STAGE2_CHROOT; then
	mkdir $STAGE2_CHROOT
	mkdir -p $STAGE2_PACKAGES
fi

if test ! -d $STAGE2_BUILD; then

	# prepare the build enviroment
	
	mkdir $STAGE2_BUILD
	cd $STAGE2_BUILD || exit 1

	# TODO: check makepkg in stage1 hdd
	# TODO: makepkg patch to run as root or add a build user to hdd
	# TODO: we assume we have on cpu for now on the target
	# TODO: fix pacman.conf in stage1:
	# architecture?
	# mirrorlist
	# pacman.conf: remove standard repos, add temp repo:
	#	[temp]
	#SigLevel = Never
	#Server = file:///packages/$arch

	# tty group for util-linux
	getent group tty >/dev/null || groupadd -g 5 tty
	
	echo "Prepared the stage 2 build environment."
fi

echo "Stage 2 ready."
