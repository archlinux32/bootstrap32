#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# build all packages for stage 2 using the target system with stage 1
# packages.  packages will be installed with pacman onto the target
# system once built sucessfully. The artifacts are also copied back
# to the $STAGE2_PACKAGES to speed up rebuild of the state of the stage 1
# system in case of destroying it.

# build bash first as 'cd subpackage' in autoconf generated makefiles break
# with cross-compiled bash

# build pacman-mirrorlist last because of a failing "package exists" test
# clash with pacman

PACKAGES="bash
iana-etc filesystem linux-api-headers tzdata
ncurses readline joe
attr acl m4 gmp gdbm db perl openssl
libunistring gettext perl-locale-gettext help2man
autoconf automake perl-error pcre2 git libtool
zlib pambase cracklib libtirpc flex pam libcap coreutils
util-linux pkg-config e2fsprogs expat bzip2 lz4 xz pcre less gzip
tar libarchive curl
archlinux-keyring archlinux32-keyring pacman
elfutils sed texinfo grep findutils file diffutils ed patch
fakeroot
kbd procps-ng bison shadow
inetutils bc kmod linux
"
#~ uinit nasm syslinux
#~ net-tools libmnl libnfnetlink iptables iproute2
#~ libedit openssh
#~ make mpfr gawk libmpc binutils gcc glibc
#~ libunwind strace gdb"
#~ pacman-mirrorlist


for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage2_package.sh" "$p" || exit 1
done

