#!/bin/sh

. "./default.conf"

# builds a hard disk image for a stage 1 system:
# no ramdisk, no modules, no fancy startup, just a shell script

cd $CROSS_HOME

umount mnt
rm -rf mnt
sudo /sbin/losetup -d /dev/loop2
sudo rm -f arch486.img

# prepare a plain image

qemu-img create arch486.img 4g
chmod 666 arch486.img
sudo /sbin/losetup /dev/loop2 arch486.img
sudo dd if=/dev/zero of=/dev/loop2 bs=512 count=32130
echo ';' | sudo /sbin/sfdisk --no-reread /dev/loop2
sudo sfdisk -A /dev/loop2 1
sudo partx --show /dev/loop2
sudo partx -v --add /dev/loop2
sudo mkfs.ext4 -O ^64bit /dev/loop2p1
mkdir mnt
sudo mount /dev/loop2p1 mnt
sudo cp -a i486-root/* mnt/.
sudo chown -R cross:cross mnt/.
cd mnt

# A simple ISOlinux boot loader booting from first partition, starting
# uinit wich start /etc/init/boot

mkdir boot/syslinux
echo 'default /boot/vmlinuz-linux root=/dev/hda1 init=/sbin/init console=ttyS0 console=tty0' \
	> boot/syslinux/syslinux.cfg
sudo dd bs=440 count=1 if=/usr/lib/syslinux/bios/mbr.bin of=/dev/loop2
cp /usr/lib/syslinux/bios/*.c32 boot/syslinux/.
sudo extlinux --install boot/syslinux/
mkdir -p etc/init

# the unit boot script configuring virtual filesystems, the network
# and starts an SSH daemon

cat >etc/init/boot <<EOF
#!/bin/sh
mount -t proc proc /proc
ln -s /proc/self/fd /dev/fd
mkdir /dev/pts
mount -t devpts devpts /dev/pts
mount -t sysfs sys /sys
mount -o remount,rw /
ip link set up dev eth0
ip addr add 192.168.1.127/24 dev eth0
ip route add default via 192.168.1.1 dev eth0
/usr/sbin/sshd
exec /usr/bin/bash
EOF
cat > etc/resolv.conf <<EOF
nameserver 192.168.1.1
EOF

# SSH confiuration: nobody user and host keys, keys for key based login

cat >> etc/group <<EOF
nobody:x:99:
EOF
cat >> etc/passwd <<EOF
nobody:x:99:99:nobody:/:/usr/bin/nologin
EOF
cat >> etc/ssh/sshd_config <<EOF
PermitRootLogin yes
EOF
ssh-keygen -b 2048 -t rsa -f etc/ssh/ssh_host_rsa_key -N ''
ssh-keygen -b 1024 -t dsa -f etc/ssh/ssh_host_dsa_key -N ''
ssh-keygen -b 521 -t ecdsa -f etc/ssh/ssh_host_ecdsa_key -N ''
ssh-keygen -b 2048 -t ed25519 -f etc/ssh/ssh_host_ed25519_key -N ''
chmod 0400 etc/ssh/ssh_host_*_key
mkdir root/.ssh
cp $HOME/.ssh/id_rsa.pub root/.ssh/authorized_keys

# add some test programs to test the C and C++ compiler

cat > root/test.c <<EOF
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main( int argc, char *argv[] )
{
    puts( "hello" );
    exit( EXIT_SUCCESS );
}
EOF

cat > root/test.cpp <<EOF
#include <iostream>
#include <cstdlib>

int main( void )
{
    std::cout << "hello" << std::endl;
    std::exit( EXIT_FAILURE );
}
EOF

# fix permissions (we only have root on the image)

chmod 0700 root/.ssh
sudo chown -R root:root .
sudo chmod 0775 etc/init/boot

# umount and clean up partitions and loopback devices

cd ..
sudo umount mnt
sudo partx -v --delete /dev/loop2
sudo losetup -d /dev/loop2
