#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# builds a small ISO image for installing a stage 4 system:
# it uses PXE to boot from a TFTP server (kernel and ramdisk),
# then loads the ISO as NBD block device. This is for installation
# on old machines with only very limited amount of RAM (currently
# requires 64 MB minimal)

sudo rm -rf $STAGE4_ISOLINUX

# copy chroot to ISOlinux dir
mkdir $STAGE4_ISOLINUX
sudo cp -a $STAGE4_CHROOT/{bin,boot,dev,etc,home,lib,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var} $STAGE4_ISOLINUX/.
sudo chown -R cross:cross $STAGE4_ISOLINUX/.
cd $STAGE4_ISOLINUX || exit 1

# on the TFTP server (e. g. as pxelinux.cfg/default)
mkdir boot/isolinux
cat >boot/isolinux/isolinux.cfg <<EOF
default menu.c32
prompt 0
timeout 20
ontimeout linux

label linux
initrd initramfs-linux.img
linux vmlinuz-linux
append rw ip=:::::eth0:dhcp nbd_host=192.168.1.12 nomodeset init=/lib/systemd/systemd nbd_name=archiso root=/dev/nbd0 console=tty0
EOF
sudo chown cross:cross boot/isolinux/isolinux.cfg

sudo chown -R root:root .
sudo chmod 0775 etc/init/boot
sudo cp /usr/lib/syslinux/bios/ldlinux.c32 boot/isolinux/.
sudo cp /usr/lib/syslinux/bios/menu.c32 boot/isolinux/.
sudo cp /usr/lib/syslinux/bios/libutil.c32 boot/isolinux/.
sudo cp /usr/lib/syslinux/bios/isolinux.bin boot/isolinux/.
sudo genisoimage -J -r -o ../arch486-stage4.iso -b boot/isolinux/isolinux.bin \
	-c boot/isolinux/boot.cat -input-charset UTF-8 -no-emul-boot \
	-boot-load-size 4 -boot-info-table -joliet-long .
cd .. || exit 1

