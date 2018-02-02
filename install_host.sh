#!/bin/sh

# Install necessary tools

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
