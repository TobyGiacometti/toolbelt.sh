# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__path=

ctor() {
	$self path="${TMPDIR:-/tmp}/$BASHPID$(echo -n "${FUNCNAME[*]}${BASH_LINENO[*]}" | cksum | cut -d " " -f 1)$RANDOM"
}

#---
# See `Dir` type for full documentation.
#
# Due to security reasons, an error occurs if the directory already exists.
public__create() {
	local path && $self "$_:"
	mkdir -m 700 "$path" || exit
}

#---
# See `Dir` type for full documentation.
public__print_path() {
	local path && $self "$_:"
	echo -n "$path"
}
