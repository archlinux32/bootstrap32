#!/bin/sh

. "./default.conf"

# build all packages for stage 1 using the cross-compiler
# packages will be installed with pacman into $STAGE1_CHROOT, dependencies
# for cross-compiling packages will be installed with bsdtar into
# the sysroot of the specific cross compiler in $XTOOLS_ARCH

PACKAGES="iana-etc filesystem tzdata"

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage1_package.sh" "$p"
done

