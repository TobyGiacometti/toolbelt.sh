# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

# Dependencies:
# - hashdeep

declare self # Fix ShellCheck SC2154.

ro__data_path=

#---
# @param $1 Absolute path to the file/directory that needs integrity verification.
ctor() {
	if [[ $1 != /* ]]; then
		echo "Path to file/directory that needs verification is invalid." >&2
		exit 1
	fi

	$self data_path="$1"
}

#---
# See `Checksum` type for full documentation.
#
# The checksum is stored in a .cksum file with the same name and location as the
# file/directory that needs integrity verification.
public__calculate() {
	local data_path && $self "$_:"

	# `hashdeep` does not return an error status code if the file/directory is
	# not accessible. We therefore do the check ourselves.
	if ! [[ -r $data_path ]]; then
		echo "File/directory that needs verification is not accessible." >&2
		exit 1
	fi

	(
		# By switching to the containing directory, we can use relative paths in
		# checksum files which saves space. Additionally, leaks of the current
		# working directory (stored in checksum files) is prevented.
		cd "$(dirname "$data_path")" >/dev/null || exit
		hashdeep -c sha256 -l -r "$(basename "$data_path")" \
			>"$(basename "$data_path").cksum"
	) || exit
}

#---
# See `Checksum` type for full documentation.
public__verify() {
	local data_path && $self "$_:"
	local checksum_file=${data_path%/}.cksum

	(
		cd "$(dirname "$data_path")" >/dev/null || exit 64
		hashdeep -a -k "$(basename "$checksum_file")" -l -r -vv \
			"$(basename "$data_path")"
	) || {
		# If verification fails due to an error that has nothing to do with file
		# integrity, we treat the failure as a fatal error and exit.
		[[ $? -gt 2 ]] && exit 1 || return 1
	}
}
