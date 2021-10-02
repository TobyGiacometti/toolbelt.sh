# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__path=

#---
# @param $1 Absolute path to the log file.
ctor() {
	if [[ $1 != /* ]]; then
		echo "Path is invalid." >&2
		exit 1
	fi

	$self path="$1"
}

#---
# See `LogFile` type for full documentation.
public__record_information() {
	local path && $self "$_:"
	tee -a "$path" || exit
}
