#!/bin/bash

# shellcheck source=./default.conf
. "./default.conf"

# TODO: getopts
DOT=1

# local cache dir
CACHE_DIR="$SCRIPT_DIR/cache"
if test ! -d "$CACHE_DIR"; then
	mkdir -p "$CACHE_DIR"
fi

# Compute dependencies and make-dependencies to build packages in stage1,
# stage2 or stage3

tmp_dir=$(mktemp -d 'tmp.compute-dependencies.0.XXXXXXXXXX' --tmpdir)
trap 'rm -rf --one-file-system "${tmp_dir}"' EXIT

# all top-level packages in base and base-devel
if test ! -f "$CACHE_DIR/group.base"; then
	echo "INFO: Caching packages for group 'base'.." >&2
	pacman -Qg base | cut -f 2 -d ' ' > "$CACHE_DIR/group.base"
fi
TOP_BASE_PACKAGES=$(cat "$CACHE_DIR/group.base")
if test ! -f "$CACHE_DIR/group.base-devel"; then
	echo "INFO: Caching packages for group 'base-devel'.." >&2
	pacman -Qg base-devel | cut -f 2 -d ' ' > "$CACHE_DIR/group.base-devel"
fi
TOP_BASE_DEVEL_PACKAGES=$(cat "$CACHE_DIR/group.base-devel")
STAGE1_PACKAGES="iana-etc filesystem linux-api-headers tzdata ncurses readline bash joe attr acl gmp gdbm db perl openssl zlib pambase cracklib libtirpc pam libcap coreutils util-linux e2fsprogs expat bzip2 lz4 xz pcre less gzip tar libarchive curl pacman-mirrorlist archlinux-keyring archlinux32-keyring pacman elfutils sed texinfo grep findutils file diffutils ed patch fakeroot kbd procps-ng shadow inetutils bc kmod linux uinit nasm syslinux net-tools libmnl libnfnetlink iptables iproute2 libedit openssh make mpfr gawk libmpc binutils gcc glibc libunwind strace gdb"
TOP_PACKAGES="$TOP_BASE_PACKAGES $TOP_BASE_DEVEL_PACKAGES $STAGE1_PACKAGES"

# get dependencies
for package in $TOP_PACKAGES; do
	if test ! -f "$CACHE_DIR/$package.pactree"; then
		echo "INFO: Caching pactree for $package.." >&2
		pactree -l "$package" > "$CACHE_DIR/$package.pactree"
	fi
done

mkdir "$tmp_dir/work"
cd "$tmp_dir/work"

# get srcinfo
for package in $TOP_PACKAGES; do
	if test ! -f "$CACHE_DIR/$package.srcinfo"; then
		echo "INFO: Caching SRCINFO for $package.." >&2
		asp export $package >"$tmp_dir/$package.asp_output" 2>&1
		# asp makes redirects like '==>' ignore those and use the pointee
		if test "$(head -n1 "$tmp_dir/$package.asp_output" | grep -c '==> .* is part of' )" == 1; then
			_tmp=$(head -n1 "$tmp_dir/$package.asp_output" | sed 's/==> \(.*\)/\1/')
			SUB_PACKAGE=$(echo "$_tmp" | cut -f 1 -d ' ')
			ADD_PACKAGE=$(echo "$_tmp" | rev | cut -f 1 -d ' ' | rev)
			# TODO: we should map sub packages to packages everywhere
			echo "WARN: seen a redirect from $SUB_PACKAGE to $ADD_PACKAGE" >&2
			continue;
		fi
		if test -d "$package"; then
			cd $package || exit 1
			makepkg --printsrcinfo > "$CACHE_DIR/$package.srcinfo"
		fi
	fi
done

cat "$CACHE_DIR"/*.pactree > "$tmp_dir/dependencies"

# all packages needed
ALL_PACKAGES="$(cat "$tmp_dir/dependencies" | sort | uniq)"

export CARCH='x86_64'

canonize_package( )
{
	_p=$1
	if test $(echo $_p | grep -c '>=') -gt 0; then
		_p=$(echo $_p | cut -f 1 -d '>')
	fi
}
	
get_dependencies( )
{
	package=$1
	mode=$2
	
	asp show $package >"${tmp_dir}/$package.PKGBUILD"
	# asp makes redirects like '==>' ignore those and use the pointee
	if test "$(head -n1 "${tmp_dir}/$package.PKGBUILD" | grep -c '==>' )" == 1; then
		_tmp=$(head -n1 "${tmp_dir}/$package.PKGBUILD" | sed 's/==> \(.*\)/\1/')
		SUB_PACKAGE=$(echo "$_tmp" | cut -f 1 -d ' ')
		ADD_PACKAGE=$(echo "$_tmp" | rev | cut -f 1 -d ' ' | rev)
		# TODO: we should map sub packages to packages everywhere
		echo "WARN: seen a redirect from $SUB_PACKAGE to $ADD_PACKAGE" >&2
		unset depends
		return
	fi
	_depends=$(. ${tmp_dir}/$package.PKGBUILD; echo "${depends[@]}")
	if test "$_depends" != ""; then
		for subpackage in $_depends; do
			canonize_package "$subpackage"
			subpackage=$_p
			depends+=( "$subpackage" )
			#get_dependencies "$subpackage" "$mode"
		done
	fi
}

if test "$DOT" = 1; then
	cat <<EOF
digraph dependencies {
	fontname=dejavu;
EOF
fi

if test "$DOT" = 1;then
	for package in $TOP_BASE_PACKAGES; do
		cat <<EOF
	"$package" [fontcolor="#00ff00"];
EOF
	done
	for package in $TOP_BASE_DEVEL_PACKAGES; do
		cat <<EOF
	"$package" [fontcolor="#0000ff"];
EOF
	done
	for package in $STAGE1_PACKAGES; do
		cat <<EOF
	"$package" [fontcolor="#ff0000"];
EOF
	done
fi

for package in $ALL_PACKAGES; do
	unset depends
	declare -a depends
	get_dependencies "$package" "depends"
	if test -v depends; then
		if test "$DOT" = 0; then
			echo -n "$package: "
		fi
		for depend in "${depends[@]}"; do
			if test "$DOT" = 1; then
				cat <<EOF
	"$package" -> "$depend"
EOF
			else
				echo -n "$depend "
			fi
		done
		echo
	fi
done

if test "$DOT" = 1; then
	cat <<EOF
}
EOF
fi

# DOT=0
# ./compute_dependencies.sh  > stage2

# DOT=1
# ./compute_dependencies.sh > graph.dot
# dot -Tpng -o graph.png graph.dot
