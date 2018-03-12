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
curl pacman-mirrorlist archlinux-keyring archlinux32-keyring
pacman
wget
python quota-tools perl-xml-parser intltool
re2c python2 ninja
python-pip-bootstrap python-pip
python-pyparsing python-packaging python-appdirs python-six python-setuptools
meson
gperf systemd dbus libusb usbutils libpcap iptables util-linux
procps-ng pcmciautils openresolv netctl dhcpcd
mkinitcpio-busybox mkinitcpio
glib2 pkg-config
ldns openssh
zip nspr gyp nss
libaio boost
"

# gyp used for mozilla sub certs, continue to use shim?
# ca-certificates-cacerts ca-certificates
# nss:
# gyp fails with:
# ImportError: This platform lacks a functioning sem_open implementation, therefore, the required synchronization primitives needed will not function, see issue 3770.

# TODO: redo make with guile
# guile, guile2_0: libtool fails to find gc (threading problem?),
# --disable-threads in toolchain causes POSIX threads to be absent, we
# wait for full toolchain to be around.
# guile, posix thread missing in toolchain
#~ make: glibc guile 
#~ gdb: python guile2.0
#~ guile2.0:  gc (with posix threads) 
# wait for posix threads, gcc toolchain rebuild

# lvm knot
# lvm2, device-mapper: systemd, thin-povisioning-tools
#~ thin-provisioning-tools: expat gcc-libs libaio boost
# boost:  #  error "Threading support unavaliable: it has been explicitly disabled with BOOST_DISABLE_THREADS"
# => now we really need the toolchain with POSIX threads
#~ cryptsetup: device-mapper popt libutil-linux

#~ linux build full with mkinitcpio and modules
     
#~  linux 
#~ make <mpfr> <gawk> <libmpc> <binutils> <gcc> glibc
#~ <libunwind> <strace> gdb
#~ "
#~ #TODO after nasm: syslinux

#~ base cryptsetup
#~ base device-mapper
#~ base lvm2

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage3_package.sh" "$p" || exit 1
done

