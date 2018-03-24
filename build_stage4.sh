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
libxml2 emacs-nox
attr acl m4 gmp gdbm db perl openssl
libunistring gettext perl-locale-gettext help2man
autoconf tcl expect dejagnu cscope automake
perl-test-pod perl-devel-symdump perl-pod-coverage
perl-test-pod-coverage perl-error pcre2
docbook-xml libxslt docbook-xsl xmlto asciidoc git
libtool
zlib pambase cracklib libtirpc flex gpm w3m pam
libcap coreutils util-linux pkg-config e2fsprogs
expat bzip2 lz4 xz pcre less gzip
tar libarchive curl
pacman-mirrorlist archlinux-keyring archlinux32-keyring
sharutils perl-text-charwidth perl-text-wrapi18n 
perl-term-readkey perl-sgmls
perl-inc-latest perl-par-dist perl-sub-identify perl-super
perl-module-build perl-test-mockmodule perl-archive-zip
perl-mime-charset libdatrie libthai perl-unicode-linebreak
po4a fakeroot fakechroot pacman
elfutils sed texinfo grep findutils file diffutils ed patch
kbd procps-ng bison shadow
inetutils bc kmod linux
which
"

#~ stage2:
#~ PACKAGES="
#~            
#~    
#~           
#~    
#~      uinit nasm 
#~ net-tools libmnl libnfnetlink iptables iproute2
#~ libedit openssh
#~ make mpfr gawk libmpc binutils gcc glibc
#~ libunwind strace gdb
#~ "

# Archlinux base, base-devel groups
#~ cryptsetup
#~ device-mapper
#~ dhcpcd
#~ gawk
#~ gcc-libs
#~ glibc
#~ iproute2
#~ iputils
#~ jfsutils
#~ licenses
#~ logrotate
#~ lvm2
#~ man-db
#~ man-pages
#~ mdadm
#~ netctl
#~ pciutils
#~ pcmciautils
#~ psmisc
#~ reiserfsprogs
#~ s-nail
#~ sysfsutils
#~ systemd-sysvcompat
#~ usbutils
#~ xfsprogs

#~ binutils
#~ gawk
#~ gcc
#~ groff
#~ make
#~ pacman
#~ sudo
#~ systemd

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage4_package.sh" "$p" || exit 1
done

