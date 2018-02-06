#!/bin/sh

. "./default.conf"

# builds a small ISO image for stage 1 system:
# no ramdisk, no modules, no fancy startup, just a shell script

sudo rm -rf $STAGE1_ISOLINUX

# copy chroot to ISOlinux dir
mkdir $STAGE1_ISOLINUX
sudo cp -a $STAGE1_CHROOT/* $STAGE1_ISOLINUX/.
sudo chown -R cross:cross $STAGE1_ISOLINUX/.
cd $STAGE1_ISOLINUX

# simple ISOlinux menu, with options for fast choosing a root device
mkdir boot/isolinux
cat >boot/isolinux/isolinux.cfg <<EOF
UI menu.c32
TIMEOUT 300
PROMPT 1
LABEL hda
	KERNEL /boot/vmlinuz-linux
	APPEND root=/dev/hda init=/sbin/init console=ttyS0 console=tty0'
LABEL hdb
	KERNEL /boot/vmlinuz-linux
	APPEND root=/dev/hdb init=/sbin/init console=ttyS0 console=tty0'
LABEL hdc
	KERNEL /boot/vmlinuz-linux
	APPEND root=/dev/hdc init=/sbin/init console=ttyS0 console=tty0'
LABEL hdd
	KERNEL /boot/vmlinuz-linux
	APPEND root=/dev/hdd init=/sbin/init console=ttyS0 console=tty0'
LABEL sr0
	KERNEL /boot/vmlinuz-linux
	APPEND root=/dev/sr0 init=/sbin/init console=ttyS0 console=tty0'
LABEL sr1
	KERNEL /boot/vmlinuz-linux
	APPEND root=/dev/sr1 init=/sbin/init console=ttyS0 console=tty0'
EOF
sudo chown cross:cross boot/isolinux/isolinux.cfg

mkdir -p etc/init

cat >etc/init/boot <<EOF
#!/bin/sh
mount -t proc proc /proc
ln -s /proc/self/fd /dev/fd
mount -t sysfs sys /sys
mount -t tmpfs nodev,nosuid,size=4M /tmp
exec /usr/bin/bash
EOF
sudo chown -R root:root .
sudo chmod 0775 etc/init/boot
sudo cp /usr/lib/syslinux/bios/ldlinux.c32 boot/isolinux/.
sudo cp /usr/lib/syslinux/bios/menu.c32 boot/isolinux/.
sudo cp /usr/lib/syslinux/bios/libutil.c32 boot/isolinux/.
sudo cp /usr/lib/syslinux/bios/isolinux.bin boot/isolinux/.
sudo genisoimage -J -r -o ../arch486.iso -b boot/isolinux/isolinux.bin \
	-c boot/isolinux/boot.cat -input-charset UTF-8 -no-emul-boot \
	-boot-load-size 4 -boot-info-table -joliet-long .
cd ..

