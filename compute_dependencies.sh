#!/bin/bash

# shellcheck source=./default.conf
. "./default.conf"

# Compute dependencies and make-dependencies to build packages in stage1,
# stage2 or stage3

tmp_dir=$(mktemp -d 'tmp.compute-dependencies.0.XXXXXXXXXX' --tmpdir)
trap 'rm -rf --one-file-system "${tmp_dir}"' EXIT

# all top-level packages in base and base-devel
TOP_PACKAGES=$(pacman -Qg base base-devel | cut -f 2 -d ' ')

# get dependencies
for package in $TOP_PACKAGES; do
	pactree -l $package >>${tmp_dir}/dependencies
done

# all packages needed
ALL_PACKAGES=$(cat ${tmp_dir}/dependencies | sort | uniq)

export CARCH='x86_64'

get_dependencies( )
{
	package=$1
	mode=$2
	
	asp show $package >${tmp_dir}/$package.PKGBUILD
	# temporary hotfix for FS#57524
	if test "$(head -n1 ${tmp_dir}/$package.PKGBUILD | grep -c '^\$Id\$$' )" == 1; then
		sed -i 's/^\(\$Id\$\)$/#\1/' ${tmp_dir}/$package.PKGBUILD
	fi
	# asp makes redirects like '==>' ignore those and use the pointee
	if test "$(head -n1 ${tmp_dir}/$package.PKGBUILD | grep -c '==>' )" == 1; then
		_tmp=$(head -n1 ${tmp_dir}/$package.PKGBUILD | sed 's/==> \(.*\)/\1/')
		SUB_PACKAGE=$(echo $_tmp | cut -f 1 -d ' ')
		ADD_PACKAGE=$(echo $_tmp | rev | cut -f 1 -d ' ' | rev)
		# TODO: we should map sub packages to packages everywhere
		echo "WARN: seen a redirect from $SUB_PACKAGE to $ADD_PACKAGE" >&2
		return
	fi
	_depends=$(. ${tmp_dir}/$package.PKGBUILD; echo "${depends[@]}")
	for subpackage in "${_depends[@]}"; do
		get_dependencies "$subpackage" "$mode"
	done
	depends+=( "${_depends[@]}" )
	#makedepends=$(. ${tmp_dir}/$package.PKGBUILD; echo "${makedepends[@]}")
	# TODO handle version constraints
	#checkdepends=$(. ${tmp_dir}/$package.PKGBUILD; echo "${checkdepends[@]}")
	#echo $package
	#printf "\tdepends: $depends\n"
	#printf "\tmakedepends: $makedepends\n"
	#printf "\tcheckdepends: $checkdepends\n"
	#echo "${depends[@]}"
	#echo "${makedepends[@]}"
}

for package in $ALL_PACKAGES; do
	unset depends
	declare -a depends
	get_dependencies "$package" "depends"
	echo "$package" "${depends[@]}"
done

# ./compute_dependencies.sh | tr -s ' ' '\n' | sort | uniq > depends
# ./compute_dependencies.sh | tr -s ' ' '\n' | sort | uniq > makedepends
# grep -xf depends makedepends > makedepends_already_depends
# grep -vxf depends makedepends > new_makedepends
