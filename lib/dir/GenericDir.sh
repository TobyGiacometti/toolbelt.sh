# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__path=

#---
# @param $1 Absolute path to the directory.
ctor() {
	if [[ $1 != /* ]]; then
		echo "Directory path is invalid." >&2
		exit 1
	fi

	$self path="$1"
}

#---
# See `Dir` type for full documentation.
public__create() {
	local path && $self "$_:"
	mkdir -p "$path" || exit
}

#---
# See `Dir` type for full documentation.
public__print_path() {
	local path && $self "$_:"
	[[ $path =~ /*$ ]]
	echo -n "${path%${BASH_REMATCH[0]}}"
}
