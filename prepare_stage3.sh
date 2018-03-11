#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# prepare the i486-build for stage 3

if test ! -d $STAGE3_CHROOT; then
	mkdir $STAGE3_CHROOT
	mkdir -p $STAGE3_PACKAGES
fi

if test ! -d $STAGE3_BUILD; then

	# prepare the build enviroment
	
	mkdir $STAGE3_BUILD
	cd $STAGE3_BUILD || exit 1

	# TODO: actually build a stage2 hdd from the build artifacts of
	# stage 2, for now we just copy the vm from stage1 after building
	# and installing all packages from stage 2 and use it as new build
	# machine.

	# systemd-journal group for systemd
	getent group systemd-journal >/dev/null || groupadd -g 190 systemd-journal
	
	echo "Prepared the stage 3 build environment."
fi

echo "Stage 3 ready."
