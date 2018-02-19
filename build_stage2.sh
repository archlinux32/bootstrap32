#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# build all packages for stage 2 using the target system with stage 1
# packages.  packages will be installed with pacman onto the target
# system once built sucessfully. The artifacts are also copied back
# to the $STAGE2_PACKAGES to speed up rebuild of the state of the stage 1
# system in case of destroying it.

PACKAGES="bash"

# build bash first as 'cd subpackage' in autoconf generated makefiles break
# with cross-compiled bash

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage2_package.sh" "$p" || exit 1
done

