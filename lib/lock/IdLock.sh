# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

# Dependencies:
# - flock

declare self # Fix ShellCheck SC2154.

ro__id=
ro__lock_dir=
ro__fd=

#---
# @param $1 ID for the lock. Please note that only alphanumeric characters and
#           `_` are allowed in lock IDs.
# @param $2 `../dir/Dir` instance. If not provided, `../dir/XdgDataDir` is used
#           to store internal lock files.
ctor() {
	local lock_dir

	if ! [[ $1 =~ ^[A-Za-z0-9_]+$ ]]; then
		echo "ID is invalid." >&2
		exit 1
	elif [[ -n $2 ]] && ! is_object "$2"; then
		echo "Lock directory value is invalid." >&2
		exit 1
	fi

	if [[ -z $2 ]]; then
		new lock_dir ../dir/XdgDataDir locks
	else
		lock_dir=$2
	fi

	$self id="$1"
	$self lock_dir="$lock_dir"
}

#---
# See `Lock` type for full documentation.
public__acquire() {
	[[ -z $1 ]] && set 0

	local lock_dir && $self "$_:"
	local fd && $self "$_:"
	local id && $self "$_:"

	if ! [[ $1 =~ ^[0-9]+$ ]]; then
		echo "Timeout value is invalid." >&2
		exit 1
	fi

	$lock_dir create

	if [[ -z $fd ]]; then
		fd=3
		while true; do
			: <&"$fd" || break # Try to copy FD. If it is not used, copy fails.
			((fd++))
		done 2>/dev/null
		$self fd="$fd"
	fi

	eval 'exec '"$fd"'>"$($lock_dir print_path && echo "/$id")"' || exit

	flock --timeout "$1" "$fd"
}

#---
# See `Lock` type for full documentation.
public__release() {
	local fd && $self "$_:"

	if [[ -z $fd ]]; then
		return 0
	fi

	flock --unlock "$fd"
}
