#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# build all packages for stage 3 using the target system with stage 2
# packages.  packages will be installed with pacman onto the target
# system once built sucessfully. The artifacts are also copied back
# to the $STAGE3_PACKAGES to speed up rebuild of the state of the stage 2
# system in case of destroying it.

PACKAGES="which"

# stage3 (from compute_dependencies.sh)
#~ acl: attr 
#~ argon2: glibc 
#~ attr: glibc 
#~ autoconf: awk m4 diffutils sh 
#~ automake: perl bash 
#~ bash: readline glibc ncurses 
#~ bc: readline 
#~ binutils: glibc zlib 
#~ bison: glibc m4 sh 
#~ bzip2: glibc sh 
#~ ca-certificates-cacert: ca-certificates-utils 
#~ coreutils: glibc acl attr gmp libcap openssl 
#~ cracklib: glibc zlib 
#~ cryptsetup: device-mapper libgcrypt popt libutil-linux json-c argon2 
#~ curl: ca-certificates krb5 libssh2 openssl zlib libpsl libnghttp2 
#~ db: gcc-libs sh 
#~ dbus: libsystemd expat 
#~ dhcpcd: glibc sh udev libsystemd 
#~ diffutils: glibc bash 
#~ e2fsprogs: sh libutil-linux 
#~ ed: glibc sh 
#~ elfutils: gcc-libs zlib bzip2 xz 
#~ expat: glibc 
#~ fakeroot: glibc filesystem sed util-linux sh 
#~ file: glibc zlib 
#~ filesystem: iana-etc 
#~ findutils: glibc sh 
#~ flex: glibc m4 sh 
#~ gawk: sh glibc mpfr 
#~ gc: gcc-libs libatomic_ops 
#~ gdbm: glibc sh 
#~ gettext: gcc-libs acl sh glib2 libunistring 
#~ glib2: pcre libffi libutil-linux zlib 
#~ gmp: gcc-libs sh 
#~ gnupg: npth libgpg-error libgcrypt libksba libassuan pinentry bzip2 readline gnutls sqlite 
#~ gnutls: gcc-libs libtasn1 readline zlib nettle p11-kit libidn libunistring 
#~ grep: glibc pcre 
#~ groff: perl gcc-libs 
#~ guile: gmp libltdl ncurses texinfo libunistring gc libffi 
#~ guile2.0: gmp libltdl ncurses texinfo libunistring gc libffi 
#~ gzip: glibc bash less 
#~ inetutils: pam libcap 
#~ iproute2: glibc iptables libelf 
#~ iptables: glibc bash libnftnl libpcap 
#~ iputils: openssl sysfsutils libcap libidn 
#~ jfsutils: util-linux 
#~ joe: ncurses 
#~ json-c: glibc 
#~ kbd: glibc pam 
#~ keyutils: glibc sh 
#~ kmod: glibc zlib xz 
#~ krb5: e2fsprogs libldap keyutils 
#~ ldns: openssl dnssec-anchors 
#~ less: glibc ncurses pcre 
#~ libarchive: acl attr bzip2 expat lz4 openssl xz zlib 
#~ libassuan: libgpg-error 
#~ libatomic_ops: glibc 
#~ libcap: glibc attr 
#~ libcap-ng: glibc 
#~ libedit: ncurses 
#~ libffi: glibc 
#~ libgcrypt: libgpg-error 
#~ libgpg-error: glibc sh 
#~ libidn: glibc 
#~ libidn2: libunistring 
#~ libksba: bash libgpg-error glibc 
#~ libmnl: glibc 
#~ libmpc: mpfr 
#~ libnfnetlink: glibc 
#~ libnftnl: libmnl 
#~ libnghttp2: glibc 
#~ libnl: glibc 
#~ libpcap: glibc libnl sh libusbx dbus 
#~ libpipeline: glibc 
#~ libpsl: libidn2 libunistring 
#~ libseccomp: glibc 
#~ libsecret: glib2 libgcrypt 
#~ libssh2: openssl 
#~ libtasn1: glibc 
#~ libtirpc: krb5 
#~ libtool: sh tar glibc 
#~ libunistring: glibc 
#~ libunwind: glibc xz 
#~ libusb: glibc libsystemd 
#~ logrotate: popt gzip acl 
#~ lz4: glibc 
#~ m4: glibc bash 
#~ make: glibc guile 
#~ man-db: bash gdbm zlib groff libpipeline less libseccomp 
#~ mdadm: glibc 
#~ mkinitcpio: awk mkinitcpio-busybox kmod util-linux libarchive coreutils bash findutils grep filesystem gzip systemd 
#~ mpfr: gmp 
#~ nano: ncurses file sh 
#~ nasm: glibc 
#~ ncurses: glibc gcc-libs 
#~ net-tools: glibc 
#~ netctl: coreutils iproute2 openresolv systemd 
#~ nettle: gmp 
#~ openresolv: bash 
#~ openssh: krb5 openssl libedit ldns 
#~ openssl: perl 
#~ p11-kit: glibc libtasn1 libffi 
#~ pacman: bash glibc libarchive curl gpgme pacman-mirrorlist archlinux-keyring 
#~ pam: glibc cracklib libtirpc pambase 
#~ patch: glibc attr 
#~ pciutils: glibc hwids kmod 
#~ pcmciautils: systemd 
#~ pcre: gcc-libs readline zlib bzip2 bash 
#~ pcre2: gcc-libs readline zlib bzip2 bash 
#~ perl: gdbm db glibc 
#~ pinentry: ncurses libcap libassuan libsecret 
#~ pkg-config: glib2 
#~ popt: glibc 
#~ procps-ng: ncurses libsystemd 
#~ psmisc: ncurses 
#~ python: expat bzip2 gdbm openssl libffi zlib 
#~ readline: glibc ncurses libncursesw.so 
#~ reiserfsprogs: util-linux 
#~ s-nail: openssl krb5 libidn 
#~ sed: glibc acl attr 
#~ shadow: bash pam acl 
#~ strace: perl libunwind 
#~ sudo: glibc libgcrypt pam libldap 
#~ sysfsutils: glibc 
#~ tar: glibc acl attr 
#~ texinfo: ncurses gzip perl sh 
#~ thin-provisioning-tools: expat gcc-libs libaio 
#~ usbutils: libusb hwids 
#~ vi: ncurses 
#~ which: glibc bash 
#~ xfsprogs: sh libutil-linux readline 
#~ xz: sh 
#~ zlib: glibc 

#~ stage2:
#~ bash
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
#~ #TODO after nasm: syslinux

for p in $PACKAGES; do
	"$SCRIPT_DIR/build_stage3_package.sh" "$p" || exit 1
done

