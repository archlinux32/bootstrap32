#!/bin/sh

# shellcheck source=./default.conf
. "./default.conf"

# builds a hard disk image for a stage 1 system:
# no ramdisk, no modules, no fancy startup, just a shell script

cd $CROSS_HOME || exit 1

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
cd mnt || exit 1

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
ln -s /proc/self/fd/0 /dev/stdin
ln -s /proc/self/fd/1 /dev/stdout
ln -s /proc/self/fd/2 /dev/stderr
mkdir /dev/pts
mount -t devpts devpts /dev/pts
ln -s /proc/kcore /dev/core
mount -t sysfs sys /sys
mkdir /dev/shm
mount -t tmpfs shm /dev/shm
mount -o remount,rw /
ip link set up dev lo
ip addr add 127.0.0.1/8 dev lo
ip link set up dev eth0
ip addr add ${STAGE1_MACHINE_IP}/24 dev eth0
ip route add default via 192.168.1.1 dev eth0
/usr/sbin/sshd
exec /usr/bin/bash
EOF
cat > etc/resolv.conf <<EOF
nameserver 192.168.1.1
EOF

# have a host name for IPv4 loopback
cat > etc/hosts <<EOF
127.0.0.1       localhost.localdomain   localhost
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
cp "$HOME/.ssh/id_rsa.pub" root/.ssh/authorized_keys

# install a build user and build directory
# tty group for coreutils
# systemd-journal group for systemd
cat >> etc/group <<EOF
tty:x:5:
systemd-journal:x:190:
build:x:1001:
EOF
cat >> etc/passwd <<EOF
build:x:1001:1001:build:/build:/bin/bash
EOF
mkdir -p build
mkdir build/.ssh
cp "$HOME/.ssh/id_rsa.pub" build/.ssh/authorized_keys
chown 1001:1001 build
# default PAM rules expect a password to be set for su?
echo 'build:xx' | chpasswd
cat > build/.bashrc <<EOF
export PATH=$PATH:/usr/bin/core_perl
EOF
chmod 0775 build/.bashrc

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

# put proper pacman.conf in place
mv etc/pacman.conf.pacnew etc/pacman.conf

# fix permissions (we only have root on the image)

chmod 0700 root/.ssh
sudo chown -R root:root .
sudo chmod 0775 etc/init/boot

# umount and clean up partitions and loopback devices

cd .. || exit 1
sudo umount mnt
sudo partx -v --delete /dev/loop2
sudo losetup -d /dev/loop2
