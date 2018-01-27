#!/bin/sh

. "./default.conf"

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
	echo "Installing crosstool-ng:"
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
	echo "Done crosstool-ng."
fi

if test ! -x $CROSS_HOME/x-tools/i486-unknown-linux-gnu/bin/i486-unknown-linux-gnu-gcc; then
	echo "Building cross compiler for i486-unknown-linux-gnu-gcc:"
	rm -rf $CROSS_HOME/{x-tools,.build,build.log,.wget-hsts,.config,.config.old}
	cp ct-ng.config $CROSS_HOME/.config
	CPUS=$(nproc)
	sed -i "s/^CT_PARALLEL_JOBS=.*/CT_PARALLEL_JOBS=$CPUS/" $CROSS_HOME/.config
	chown cross:cross $CROSS_HOME/.config
	su - cross <<EOF
ct-ng build
EOF
	echo "Done creating the cross compiler."
fi

echo -n "Cross-compiler ready: "
CROSS_MSG="$($CROSS_HOME/x-tools/i486-unknown-linux-gnu/bin/i486-unknown-linux-gnu-gcc --version | head -n 1)"
echo $CROSS_MSG
