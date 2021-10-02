# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__path=

#---
# Initialize the object.
#
# Please note that this object does not represent the XDG data directory itself
# (usually `$HOME/.local/share`), but a subdirectory that is scoped to the current
# application.
#
# The environment variable `XDG_DATA_HOME` can be used to adjust the base directory.
#
# @param $1 Path that should be appended to the directory path.
ctor() {
	local path
	local classpath && $self "$_:"

	path=${XDG_DATA_HOME:-$HOME/.local/share}/toolbelt.sh
	path=$path/$(echo -n "$classpath" | cksum | cut -d " " -f 1)
	path=$path/$1

	$self path="$path"
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
