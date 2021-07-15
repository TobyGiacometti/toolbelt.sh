# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

#---
# @var Flags are separated by a space character.
ro__supported_flags=
#---
# @var Flags are separated by a space character.
rw__active_flags=

#---
# @param $@ Flags that are supported. Please note that only alphanumeric
#           characters and `_` are allowed in flag names.
ctor() {
	local flag

	if [[ $# -eq 0 ]]; then
		echo "Specification of supported flags is required." >&2
		exit 1
	fi

	for flag in "$@"; do
		if [[ $flag =~ [^A-Za-z0-9_] ]]; then
			echo "Flag name is invalid." >&2
			exit 1
		fi
	done

	$self supported_flags="$*"
}

#---
# See `Flags` type for full documentation.
public__activate() {
	local flag
	local active_flags && $self "$_:"

	for flag in "$@"; do
		$self _ensure_supported "$flag"
		# shellcheck disable=SC2076
		if ! [[ " $active_flags " =~ " $flag " ]]; then
			active_flags="$active_flags $flag"
		fi
	done

	$self active_flags="$active_flags"
}

#---
# See `Flags` type for full documentation.
public__deactivate() {
	local flag
	local active_flags && $self "$_:"

	for flag in "$@"; do
		$self _ensure_supported "$flag"
		active_flags=" $active_flags "
		active_flags=${active_flags/ $flag / }
		active_flags=${active_flags# }
		active_flags=${active_flags% }
	done

	$self active_flags="$active_flags"
}

#---
# See `Flags` type for full documentation.
public__is_active() {
	local active_flags && $self "$_:"

	$self _ensure_supported "$1"

	# shellcheck disable=SC2076
	if [[ " $active_flags " =~ " $1 " ]]; then
		return 0
	fi

	return 1
}

#---
# @param $@ Flags that should be checked.
private__ensure_supported() {
	local flag
	local supported_flags && $self "$_:"

	for flag in "$@"; do
		# shellcheck disable=SC2076
		if ! [[ " $supported_flags " =~ " $flag " ]]; then
			echo "Flag is not supported: $flag" >&2
			exit 1
		fi
	done
}
