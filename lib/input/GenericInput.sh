# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__tty_fg_blue=$([[ $TERM =~ ^(dumb)?$ ]] || tput setaf 4)
ro__tty_fg_green=$([[ $TERM =~ ^(dumb)?$ ]] || tput setaf 2)
ro__tty_reset=$([[ $TERM =~ ^(dumb)?$ ]] || tput sgr0)
ro__prompt=
ro__valid_inputs=
ro__flags=

#---
# @param $1 Prompt that should be printed.
# @param $2 Valid inputs separated by slash. If not provided, any input is valid.
# @param... Flags that customize the functionality:
#
#           - `optional`: Input is optional.
#           - `secure`: Input does not appear in the terminal while typing.
ctor() {
	local flags

	if [[ -z $1 ]]; then
		echo "Prompt is required." >&2
		exit 1
	fi

	new flags ../flags/SupportedFlags optional secure
	$flags activate "${@:3}"

	$self prompt="$1"
	$self valid_inputs="$2"
	$self flags="$flags"
}

#---
# See `Input` type for full documentation.
public__request() {
	local tty_fg_blue && $self "$_:"
	local tty_reset && $self "$_:"
	local prompt && $self "$_:"
	local tty_fg_green && $self "$_:"
	local valid_inputs && $self "$_:"
	local read_cmd
	local flags && $self "$_:"
	local input

	# The prompt should appear in non-interactive sessions as well, so we write
	# it to STDERR instead of using `read -p`.
	echo -n "$tty_fg_blue$prompt$tty_reset " >&2
	if [[ -n $valid_inputs ]]; then
		echo -n "${tty_fg_green}[$valid_inputs]$tty_reset " >&2
	fi

	read_cmd=(read -r)
	$flags is_active secure && read_cmd+=(-s)
	read_cmd+=(input)
	IFS= "${read_cmd[@]}"
	# If input is not coming from the terminal, we simulate terminal output for
	# a more consistent experience.
	if ! [[ -t 0 ]] && ! $flags is_active secure; then
		echo "$input" >&2
	fi
	# `read -s` swallows anything that is typed. As a result, we need to manually
	# create a line break so that subsequent output is on its own line.
	$flags is_active secure && echo >&2

	if [[ -z $input ]]; then
		if ! $flags is_active optional; then
			$self request
			return
		fi
	fi

	if ! $self _is_valid "$input"; then
		$self request
		return
	fi

	echo -n "$input"
}

#---
# @param $1 Input that should be checked.
private__is_valid() {
	local valid_inputs && $self "$_:"
	local valid_input

	if [[ -z $valid_inputs ]]; then
		return 0
	fi

	IFS=/ read -r -a valid_inputs <<<"$valid_inputs"

	for valid_input in "${valid_inputs[@]}"; do
		if [[ $valid_input = "$1" ]]; then
			return 0
		fi
	done

	return 1
}
