#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# build all packages for stage 1 using the cross-compiler
# packages will be installed with pacman into $STAGE1_CHROOT, dependencies
# for cross-compiling packages will be installed with bsdtar into
# the sysroot of the specific cross compiler in $XTOOLS_ARCH

PACKAGES="iana-etc filesystem linux-api-headers tzdata
ncurses readline bash joe
attr acl gmp gdbm db perl openssl
zlib pambase cracklib libtirpc pam libcap coreutils
util-linux e2fsprogs
expat bzip2 lz4 xz pcre less gzip tar libarchive curl
pacman-mirrorlist archlinux-keyring archlinux32-keyring pacman
elfutils
sed texinfo grep findutils file diffutils ed patch
fakeroot
kbd procps-ng shadow
inetutils bc kmod linux uinit nasm syslinux
net-tools libmnl libnfnetlink iptables iproute2
libedit openssh
make mpfr gawk libmpc binutils gcc glibc
libunwind strace gdb"

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage1_package.sh" "$p" || exit 1
done

