#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# prepare the i486-build for stage 4

if test ! -d $STAGE4_CHROOT; then
	mkdir $STAGE4_CHROOT
	mkdir -p $STAGE4_PACKAGES
fi

if test ! -d $STAGE4_BUILD; then

	# prepare the build enviroment
	
	mkdir $STAGE4_BUILD
	cd $STAGE4_BUILD || exit 1

	# TODO: actually build a STAGE4 hdd from the build artifacts of
	# stage 3, for now we just copy the vm from stage2 after building
	# and installing all packages from stage 3 and use it as new build
	# machine.
	
	echo "Prepared the stage 4 build environment."
fi

echo "Stage 4 ready."
