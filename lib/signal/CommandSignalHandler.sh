# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__commands=
#---
# @var Signals are separated by a space character.
ro__signals=
rw__registered=0

#---
# @param $1 Commands that must be executed when the specified signals are received.
# @param... Signals that should be handled. Check the documentation of `trap` for
#           valid values.
ctor() {
	if [[ -z $1 ]]; then
		echo "Commands are required." >&2
		exit 1
	elif [[ -z ${*:2} ]]; then
		echo "Signals are required." >&2
		exit 1
	fi

	$self commands="$1"
	$self signals="${*:2}"
}

#---
# See `SignalHandler` type for full documentation.
#
# This implementation uses the `trap` command internally. However, additional
# logic enables the seamless registration of multiple signal handlers from
# various places in the codebase.
public__register() {
	local registered && $self "$_:"
	local signal
	local signals && $self "$_:" && IFS=" " read -r -a signals <<<"$signals"
	local commands && $self "$_:"

	if [[ $registered -eq 1 ]]; then
		return
	fi

	for signal in "${signals[@]}"; do
		trap -- "$(
			# `eval` is used to correctly handle single quotes inside trap actions.
			# `printf` is used instead of `echo` to correctly handle backslashes.
			eval "set -- $(trap -p "$signal")"
			printf "%s\n" "$3"
			printf "%s\n" "$commands"
		)" "$signal" || exit
	done

	$self registered=1
}
