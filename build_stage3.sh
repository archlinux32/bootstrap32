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
mpfr gawk libmpc binutils gcc glibc
gc guile make guile2.0 gdb
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
thin-provisioning-tools lvm2
nasm syslinux
"

# gyp used for mozilla sub certs, continue to use shim?
# ca-certificates-cacerts ca-certificates
# nss:
# gyp fails with:
# ImportError: This platform lacks a functioning sem_open implementation, therefore, the required synchronization primitives needed will not function, see issue 3770.
# => recompile python2 with a shm filesystem!
#   File "/usr/lib/python2.7/subprocess.py", line 186, in check_call
#    raise CalledProcessError(retcode, cmd)
# subprocess.CalledProcessError: Command '['/build/nss/src/nss-3.35/dist/Release/bin/shlibsign', '-v', '-i', '/build/nss/src/nss-3.35/dist/Release/lib/libfreebl3.so']' returned non-zero exit status -11
# => https://groups.google.com/forum/#!searchin/mozilla.dev.platform/2fa%7Csort:relevance/mozilla.dev.platform/eemHHhf3lBM/k9cyMceyAQAJ
# => https://bugzilla.mozilla.org/show_bug.cgi?id=1400603
# => https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=221466
# patches make situation much worse!

#~ linux build full with mkinitcpio and modules
#~  linux 

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage3_package.sh" "$p" || exit 1
done

