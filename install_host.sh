#!/bin/sh

# Install necessary tools

# shellcheck source=./default.conf
. "./default.conf"

# development stuff
pacman --noconfirm --needed -S base-devel

# for working and checking out tarballs via git, zip, etc.
pacman --noconfirm --needed -S sudo screen git asp wget unzip

# for crosstool-ng
pacman --noconfirm --needed -S gperf help2man

# for uname-hack
pacman --noconfirm --needed -S linux-headers

# for arch-chroot
pacman --noconfirm --needed -S arch-install-scripts

# for linux kernel
pacman --noconfirm --needed -S bc

# for bc
pacman --noconfirm --needed -S ed

# for pam
pacman --noconfirm --needed -S flex

# for a bootable ISO image
pacman --noconfirm --needed -S syslinux cdrtools

# for building a hard disk image
pacman --noconfirm --needed -S qemu

# for building syslinux (Intel only)
case $BUILD_CPU in
	i*86|x86_64)
		pacman --noconfirm --needed -S nasm
		;;
esac

# for groff
pacman --noconfirm --needed -S xorg-util-macros

# for building git (stage 2)
pacman --noconfirm --needed -S libgnome-keyring xmlto

# some packages come from the AUR
if test "$(grep -c '\[archlinuxfr\]' /etc/pacman.conf)" = 0; then
	cat >> /etc/pacman.conf <<EOF
[archlinuxfr]
Server = http://repo.archlinux.fr/\$arch
SigLevel = Optional DatabaseOptional
EOF

	pacman --noconfirm -Syy
	pacman --noconfirm -S --needed yaourt
fi

echo "Host ready."
