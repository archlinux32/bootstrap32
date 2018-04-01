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
autoconf autoconf-archive tcl expect dejagnu cscope automake
perl-test-pod perl-devel-symdump perl-pod-coverage
perl-test-pod-coverage perl-error pcre2
docbook-xml libxslt docbook-xsl xmlto asciidoc git
libtool
zlib pambase cracklib libtirpc flex gpm w3m
tcl sqlite postgresql
jsoncpp 
libuv rhash shared-mime-info
cmake
jemalloc lzo mariadb libsasl
chrpath unixodbc openldap
keyutils krb5 libtirpc
pam
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
libusb-compat pcsclite npth gnupg gpgme
pacman-mirrorlist archlinux-keyring archlinux32-keyring
sharutils perl-text-charwidth perl-text-wrapi18n 
perl-term-readkey perl-sgmls
perl-inc-latest perl-par-dist perl-sub-identify perl-super
perl-module-build perl-test-mockmodule perl-archive-zip
perl-mime-charset libdatrie libthai perl-unicode-linebreak
po4a fakeroot fakechroot
pacman
elfutils sed texinfo grep findutils file diffutils ed patch
check kbd bison shadow
mkinitcpio-busybox mkinitcpio
inetutils bc hwids pciutils kmod linux linux-firmware
uinit nasm ucl upx syslinux
net-tools libmnl libnfnetlink
libedit ldns openssh
which
libatomic_ops gc guile make guile2.0 gdb
libunwind strace
groff libseccomp man-db man-pages
popt logrotate psmisc linux-atm iputils sudo
libcap-ng libidn2 libnghttp2 libpsl libpipeline libmicrohttpd libssh2
argon2 json-c cryptsetup
s-nail quota-tools perl-xml-parser intltool
gperf mdadm
python re2c ninja python2
python-pip python-pyparsing python-packaging python-appdirs python-six
python-setuptools
meson
systemd dbus libusb usbutils
libical alsa-lib bluez libpcap libnftnl iptables iproute2 util-linux
procps-ng pcmciautils openresolv netctl dhcpcd
desktop-file-utils glib2 pkg-config
jfsutils reiserfsprogs xfsprogs sysfsutils
libaio boost thin-provisioning-tools lvm2
mpfr gawk libmpc binutils gcc glibc
links licenses
nbd rpcbind ding-libs gssproxy nfs-utils
mkinitcpio-nfs-utils mkinitcpio-nbd atftp
zip nspr gyp
"

# nss still fails as in stage 3

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage4_package.sh" "$p" || exit 1
done

