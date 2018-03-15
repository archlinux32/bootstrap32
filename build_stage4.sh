#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# build all packages for stage 4 using the target system with stage 3
# packages.  packages will be installed with pacman onto the target
# system once built sucessfully. The artifacts are also copied back
# to the $STAGE4_PACKAGES to speed up rebuild of the state of the stage 4
# system in case of destroying it.

PACKAGES="iana-etc filesystem linux-api-headers tzdata
ncurses readline bash joe nano vi
attr acl m4 gmp gdbm db perl openssl
libunistring gettext perl-locale-gettext help2man
autoconf
"

#~ stage2:
#~ PACKAGES="
#~    
#~     
#~    automake perl-error pcre2 git libtool
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

# Archlinux base, base-devel groups
#~ bzip2
#~ coreutils
#~ cryptsetup
#~ device-mapper
#~ dhcpcd
#~ diffutils
#~ e2fsprogs
#~ file
#~ findutils
#~ gawk
#~ gcc-libs
#~ gcc-libs
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
#~ netctl
#~ pacman
#~ pciutils
#~ pcmciautils
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
#~ which
#~ xfsprogs

#~ automake
#~ binutils
#~ bison
#~ fakeroot
#~ file
#~ findutils
#~ flex
#~ gawk
#~ gcc
#~ gettext
#~ grep
#~ groff
#~ gzip
#~ libtool
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

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage4_package.sh" "$p" || exit 1
done

