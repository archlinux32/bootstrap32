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
zlib pambase cracklib flex pam libcap coreutils
e2fsprogs expat bzip2 lz4 xz pcre less gzip
tar libarchive
icu
mpdecimal libffi 
nettle libidn libtasn1 p11-kit gnutls libgpg-error
elfutils sed texinfo grep findutils file diffutils ed patch
fakeroot
check kbd bison shadow
inetutils bc kmod
net-tools libmnl
libedit
libatomic_ops gc mpfr gawk libmpc binutils
libunwind strace
argon2
groff
json-c
libcap-ng
libpipeline libseccomp man-db man-pages
mdadm
nano
popt logrotate
hwids pciutils
keyutils
sqlite
vi
which
"

#~ util-linux: libcap-ng

# guile, guile2_0: libtool fails to find gc

# gnupg: libgcrypt 
# libcgcryt: autodetection fails brilliantly, for instalce SSE 4.1
# gets enabled!

#~ stage2:
# 
# git problem, not base of base-devel, but needed to checkout out via
# https+git protocoll. For now using the stage2 one
#
# libxml2: python2 and python as makedepends
#~ libxslt: libxml2 libgcrypt python2
#~ xmlto: libxslt docbook-xsl
#~ git: python2 emacs libgnome-keyring xmlto asciidoc
#~
#~ libsasl: postgresql-libs libmariadbclient libldap krb5
#~ libsasl: sqlite
#~ libldap: libsasl
#~ krb5: e2fsprogs libldap keyutils
#~ keyutils: glibc sh  
#~ libtirpc: krb5

#~ util-linux:
#~ pkg-config: glib2

#~ libxml2: icu
#~ libxslt: libxml2
#~ libidn2 publicsuffix-list icu
#~ libpsl: libidn2 libunistring libxslt python
#~ curl: ca-certificates krb5 libssh2 libpsl libnghttp2

#~ python: expat bzip2 gdbm openssl libffi zlib 

#~ linux build full with mkinitcpio and modules

#~ gdb: python guile2.0

#~ pacman-mirrorlist archlinux-keyring archlinux32-keyring pacman     
#~ <kbd> procps-ng <bison> <shadow>
#~ <inetutils> <bc> <kmod> linux 
#~ <net-tools> <libmnl> <libnfnetlink> iptables iproute2
#~ <libedit> openssh
#~ <make> <mpfr> <gawk> <libmpc> <binutils> <gcc> glibc
#~ <libunwind> <strace> gdb
#~ "
#~ #TODO after nasm: syslinux

# stage3 (from compute_dependencies.sh)
#~ ca-certificates-cacert: ca-certificates-utils 
#~ cryptsetup: device-mapper libgcrypt popt libutil-linux json-c argon2 
#~ dbus: libsystemd expat 
#~ dhcpcd: glibc sh udev libsystemd 
#~ glib2: pcre libffi libutil-linux zlib 
#~ gnupg: npth libgpg-error libgcrypt libksba libassuan pinentry bzip2 readline gnutls sqlite 
#~ guile2.0: gmp libltdl ncurses texinfo libunistring gc libffi 
#~ iptables: glibc bash libnftnl libpcap 
#~ iputils: openssl sysfsutils libcap libidn 
#~ jfsutils: util-linux 
#~ ldns: openssl dnssec-anchors 
#~ libarchive: acl attr bzip2 expat lz4 openssl xz zlib 
#~ libassuan: libgpg-error 
#~ libgcrypt: libgpg-error 
#~ libksba: bash libgpg-error glibc 
#~ libnfnetlink: glibc 
#~ libnftnl: libmnl 
#~ libnghttp2: glibc 
#~ libnl: glibc 
#~ libpcap: glibc libnl sh libusbx dbus 
#~ libsecret: glib2 libgcrypt 
#~ libssh2: openssl 
#~ libtirpc: krb5 
#~ libusb: glibc libsystemd 
#~ make: glibc guile 
#~ mkinitcpio: awk mkinitcpio-busybox kmod util-linux libarchive coreutils bash findutils grep filesystem gzip systemd 
#~ netctl: coreutils iproute2 openresolv systemd 
#~ openresolv: bash 
#~ openssh: krb5 openssl libedit ldns 
#~ pacman: bash glibc libarchive curl gpgme pacman-mirrorlist archlinux-keyring 
#~ pcmciautils: systemd 
#~ pinentry: ncurses libcap libassuan libsecret 
#~ pkg-config: glib2 
#~ procps-ng: ncurses libsystemd 
#~ psmisc: ncurses 
#~ reiserfsprogs: util-linux 
#~ s-nail: openssl krb5 libidn 
#~ sudo: glibc libgcrypt pam libldap 
#~ sysfsutils: glibc 
#~ thin-provisioning-tools: expat gcc-libs libaio 
#~ usbutils: libusb hwids 
#~ xfsprogs: sh libutil-linux readline 

#~ base cryptsetup
#~ base device-mapper
#~ base dhcpcd
#~ base iputils
#~ base jfsutils
#~ base licenses
#~ base lvm2
#~ base netctl
#~ base pciutils
#~ base pcmciautils
#~ base psmisc
#~ base reiserfsprogs
#~ base s-nail
#~ base systemd-sysvcompat
#~ base usbutils
#~ base xfsprogs
#~ base-devel sudo
#~ base-devel systemd

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage3_package.sh" "$p" || exit 1
done

