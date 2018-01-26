#!/bin/sh

# Prepare the cross-compiler for the destination platform, in our
# case i486.

if test ! "$(getent group cross)"; then
	groupadd cross
fi

if test ! "$(getent passwd cross)"; then
	useradd -m -g cross cross
fi

# add 'cross' user as sudoer without password
if test ! -f /etc/sudoers.d/cross; then
	echo "cross ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/cross
fi

if test ! -x /usr/local/bin/ct-ng; then
	su - cross <<EOF
mkdir cross
cd cross
git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
./bootstrap
./configure --prefix=/usr/local
make
sudo make install
cd ..
EOF
fi

if test ! -x /home/cross/x-tools/i486-unknown-linux-gnu/bin/i486-unknown-linux-gnu-gcc; then
	rm -rf /home/cross/{x-tools,.build,build.log,.wget-hsts,.config,.config.old}
	cp ct-ng.config /home/cross/.config
	CPUS=$(nproc)
	sed -i "s/^CT_PARALLEL_JOBS=.*/CT_PARALLEL_JOBS=$CPUS/" /home/cross/.config
	chown cross:cross /home/cross/.config
	su - cross <<EOF
ct-ng build
EOF
fi
