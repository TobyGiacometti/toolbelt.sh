# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__log_dir=
ro__timestamp=

#---
# @param $1 `../dir/Dir` instance that represents the directory where the log
#           file should be stored.
ctor() {
	if ! is_object "$1"; then
		echo "Log directory value is invalid." >&2
		exit 1
	fi

	$self log_dir="$1"
	$self timestamp="$(date "+%Y-%m-%dT%H%M%S")"
}

#---
# See `LogFile` type for full documentation.
#
# The name of the log file has following format:
#
# `yyyy-mm-ddThhmmss.log`
#
# For example:
#
# `2021-03-03T030000.log`
#
# The timestamp is generated during object construction.
public__record_information() {
	local log_file
	local log_dir && $self "$_:"
	local timestamp && $self "$_:"

	$log_dir create
	new log_file GenericLogFile "$($log_dir print_path)/$timestamp.log"
	$log_file record_information
}
