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
tar libarchive icu curl
mpdecimal libffi
valgrind nettle libidn libtasn1 p11-kit gnutls libgpg-error libassuan
libksba libgcrypt pinentry
perl-http-daemon perl-socket6 perl-io-socket-inet6 perl-net-ssleay
perl-io-socket-ssl
perl-http-date perl-encode-locale perl-lwp-mediatypes perl-test-needs
perl-uri perl-io-html perl-try-tiny perl-http-message perl-lwp-mediatypes
perl-http-daemon perl-io-socket-ssl
wget
libusb-compat pcsclite gnupg gpgme
pacman-mirrorlist archlinux-keyring archlinux32-keyring
sharutils perl-text-charwidth perl-text-wrapi18n 
perl-term-readkey perl-sgmls
perl-inc-latest perl-par-dist perl-sub-identify perl-super
perl-module-build perl-test-mockmodule perl-archive-zip
perl-mime-charset libdatrie libthai perl-unicode-linebreak
po4a fakeroot fakechroot
pacman
elfutils sed texinfo grep findutils file diffutils ed patch
check kbd procps-ng bison shadow
inetutils bc kmod linux uinit nasm ucl upx syslinux
net-tools libmnl libnfnetlink
libedit openssh
which
libatomic_ops gc guile make guile2.0 gdb
"

#~ mpfr gawk libmpc binutils gcc glibc

# =>
#~ 
#~  

#~ libunwind strace
#~ argon2
#~ groff
#~ jfsutils
#~ json-c
#~ libcap-ng
#~ libnftnl
#~ libidn2 libnghttp2 libpsl
#~ libpipeline libseccomp man-db man-pages
#~ libmicrohttpd
#~ libssh2
#~ mdadm
#~ nano
#~ npth
#~ popt logrotate
#~ hwids pciutils
#~ keyutils
#~ tcl sqlite libsasl chrpath unixodbc openldap
#~ krb5 libtirpc pam
#~ reiserfsprogs
#~ sysfsutils iputils
#~ s-nail
#~ vi
#~ xfsprogs
#~ psmisc
#~ sudo
#~ autoconf-archive
#~ linux-atm iproute2
#~ python quota-tools perl-xml-parser intltool
#~ re2c python2 ninja
#~ python-pip-bootstrap python-pip
#~ python-pyparsing python-packaging python-appdirs python-six python-setuptools
#~ meson
#~ gperf systemd dbus libusb usbutils libpcap iptables iproute2 util-linux
#~ procps-ng pcmciautils openresolv netctl dhcpcd
#~ mkinitcpio-busybox mkinitcpio
#~ glib2 pkg-config
#~ ldns openssh
#~ zip nspr gyp nss
#~ libaio boost
#~ thin-provisioning-tools lvm2
#~ nasm syslinux
#~ linux linux-firmware
#~ "


#~ stage2:
#~ PACKAGES="
#~            
#~   again: linux, doesn't boot? 
#~           
#~    
#~      
#~ libedit openssh
#~ make mpfr gawk libmpc binutils gcc glibc
#~ libunwind strace gdb
#~ "

# Archlinux base, base-devel groups
#~ argon2 cryptsetup
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
#~ sudo
#~ systemd

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage4_package.sh" "$p" || exit 1
done

