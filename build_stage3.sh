#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# build all packages for stage 3 using the target system with stage 2
# packages.  packages will be installed with pacman onto the target
# system once built sucessfully. The artifacts are also copied back
# to the $STAGE3_PACKAGES to speed up rebuild of the state of the stage 3
# system in case of destroying it.

PACKAGES="iana-etc filesystem linux-api-headers tzdata
ncurses readline bash joe
attr acl m4 gmp gdbm db perl openssl
libunistring gettext perl-locale-gettext help2man
autoconf automake perl-error pcre2 git libtool
zlib pambase cracklib flex libcap coreutils
e2fsprogs expat bzip2 lz4 xz pcre less gzip
tar libarchive
icu
mpdecimal libffi 
nettle libidn libtasn1 p11-kit gnutls libgpg-error libassuan
libksba libgcrypt pinentry gnupg
elfutils sed texinfo grep findutils file diffutils ed patch
fakeroot
check kbd bison shadow
inetutils bc kmod
net-tools libmnl
libedit
mpfr gawk libmpc binutils
libatomic_ops gc
libunwind strace
argon2
groff
jfsutils
json-c
libcap-ng
libnftnl
libidn2 libnghttp2 libpsl
libpipeline libseccomp man-db man-pages
libmicrohttpd
libssh2
mdadm
nano
npth
popt logrotate
hwids pciutils
keyutils
tcl sqlite libsasl chrpath unixodbc openldap
krb5 libtirpc pam
reiserfsprogs
sysfsutils iputils
s-nail
vi
which
xfsprogs
psmisc
gpgme
sudo
autoconf-archive
linux-atm iproute2
ca-certificates curl pacman-mirrorlist archlinux-keyring archlinux32-keyring
pacman
"

# TODO: redo make with guile
# guile, guile2_0: libtool fails to find gc (threading problem?),
# --disable-threads in toolchain causes POSIX threads to be absent, we
# wait for full toolchain to be around.
# guile, posix thread missing in toolchain
#~ make: glibc guile 
#~ gdb: python guile2.0
#~ guile2.0:  gc (with posix threads) 
# wait for posix threads, gcc toolchain rebuild

# building toolchain (gcc): again, lobtool problems
#/usr/lib/gcc/i486-pc-linux-gnu/7.3.0/ld: cannot find -lquadmath
#collect2: error: ld returned 1 exit status
#libtool: install: error: relink `libgfortran.la' with the above command before installing it
#make: Leaving directory '/build/gcc/src/gcc-build/i486-pc-linux-gnu/libgfortran'

# the ptyhon knot
# python executes and fails in testing. Why can't i switch off
# testing?
# 0:01:27 load avg: 1.07 [ 24/406] test_asynchat, test hangs forever!

#~ util-linux: systemd, python

# libxml2: python2 and python as makedepends
#~ libxslt: libxml2 libgcrypt python2
#~ xmlto: libxslt docbook-xsl
#~ asciidoc: python

#~ util-linux:
#~ pkg-config: glib2
#~ pkg-config: glib2 

#~ libxslt: libxml2
# ca-certificates: asciidoc, xsltproc,...

#~ python: 

#~ linux build full with mkinitcpio and modules
     
#~  linux 
#~ <libedit> openssh
#~ make <mpfr> <gawk> <libmpc> <binutils> <gcc> glibc
#~ <libunwind> <strace> gdb
#~ "
#~ #TODO after nasm: syslinux

#~ iptables: libpcap 
# libpcap: dbus libusbx

# stage3 (from compute_dependencies.sh)
#~ cryptsetup: device-mapper libgcrypt popt libutil-linux

# ldns/unbound-cyrcle
#~ ldns: openssl dnssec-anchors 
#~ dnssec-anchors: unbound
#~ unbound: ldns
#~ openssh: ldns 

# the glib2 knot
#~ glib2: libutil-linux 
#~ libsecret: glib2 libgcrypt 

# the systemd knot
#~ libusb: glibc libsystemd 
#~ usbutils: libusb hwids 
#~ netctl: openresolv systemd 
#~ openresolv: systemd 
#~ pcmciautils: systemd 
#~ procps-ng: libsystemd 
#~ libpcap: libusbx dbus 
#  systemd: libgcrypt libmicrohttpd libxslt python-lxml quota-tools gnu-efi-libs meson
#~ dbus: libsystemd expat 
#~ dhcpcd: glibc sh udev libsystemd 
# systemd: gperf intltool libxslt python-lxml quota-tools gnu-efi-libs meson
#~ util-linux: systemd, python

#~ mkinitcpio: awk mkinitcpio-busybox kmod util-linux libarchive coreutils bash findutils grep filesystem gzip systemd 

# lvm2, device-mapper: systemd, thin-povisioning-tools
#~ thin-provisioning-tools: expat gcc-libs libaio boost
# boost: we can build a non-python version
# cryptsetup: device-mapper

#~ base cryptsetup
#~ base device-mapper
#~ base dhcpcd
#~ base lvm2
#~ base netctl
#~ base pcmciautils
#~ base systemd-sysvcompat
#~ base usbutils
#~ base-devel systemd

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage3_package.sh" "$p" || exit 1
done

