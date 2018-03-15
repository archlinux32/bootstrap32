#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# build all packages for stage 4 using the target system with stage 3
# packages.  packages will be installed with pacman onto the target
# system once built sucessfully. The artifacts are also copied back
# to the $STAGE4_PACKAGES to speed up rebuild of the state of the stage 4
# system in case of destroying it.

PACKAGES=""

# Archlinux base, base-devel groups
#~ bash
#~ bzip2
#~ coreutils
#~ cryptsetup
#~ device-mapper
#~ dhcpcd
#~ diffutils
#~ e2fsprogs
#~ file
#~ filesystem
#~ findutils
#~ gawk
#~ gcc-libs
#~ gcc-libs
#~ gettext
#~ glibc
#~ grep
#~ gzip
#~ inetutils
#~ iproute2
#~ iputils
#~ jfsutils
#~ less
#~ licenses
#~ linux
#~ logrotate
#~ lvm2
#~ man-db
#~ man-pages
#~ mdadm
#~ nano
#~ netctl
#~ pacman
#~ pciutils
#~ pcmciautils
#~ perl
#~ procps-ng
#~ psmisc
#~ reiserfsprogs
#~ s-nail
#~ sed
#~ shadow
#~ sysfsutils
#~ systemd-sysvcompat
#~ tar
#~ texinfo
#~ usbutils
#~ util-linux
#~ vi
#~ which
#~ xfsprogs

#~ autoconf
#~ automake
#~ binutils
#~ binutils
#~ bison
#~ fakeroot
#~ file
#~ findutils
#~ flex
#~ gawk
#~ gcc
#~ gcc
#~ gettext
#~ grep
#~ groff
#~ gzip
#~ libtool
#~ libtool
#~ m4
#~ make
#~ pacman
#~ patch
#~ pkg-config
#~ sed
#~ sudo
#~ systemd
#~ texinfo
#~ util-linux
#~ which

#~ stage2:
#~ PACKAGES="bash
#~ iana-etc filesystem linux-api-headers tzdata
#~ ncurses readline joe
#~ attr acl m4 gmp gdbm db perl openssl
#~ libunistring gettext perl-locale-gettext help2man
#~ autoconf automake perl-error pcre2 git libtool
#~ zlib pambase cracklib libtirpc flex pam libcap coreutils
#~ util-linux pkg-config e2fsprogs expat bzip2 lz4 xz pcre less gzip
#~ tar libarchive curl
#~ pacman-mirrorlist archlinux-keyring archlinux32-keyring pacman
#~ elfutils sed texinfo grep findutils file diffutils ed patch
#~ fakeroot
#~ kbd procps-ng bison shadow
#~ inetutils bc kmod linux uinit nasm 
#~ net-tools libmnl libnfnetlink iptables iproute2
#~ libedit openssh
#~ make mpfr gawk libmpc binutils gcc glibc
#~ libunwind strace gdb
#~ "

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage4_package.sh" "$p" || exit 1
done

