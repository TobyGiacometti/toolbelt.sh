# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__option_spec=
#---
# @var Output of `declare -p`.
ro__args=

#---
# @param $1 Alphanumeric characters that can be used as command-line options. If
#           a character is followed by `:`, a value is expected for the option.
#           For example, if the options `-t example -v` need to be parsed, `t:v`
#           should be specified.
# @param... Command-line arguments that need to be parsed.
ctor() {
	if ! [[ $1 =~ ^([A-Za-z0-9]:?)+$ ]]; then
		echo "Option specification is invalid." >&2
		exit 1
	fi

	$self option_spec="$1"
	$self args="$(args=("${@:2}") && declare -p args)"
}

#---
# See `Args` type for full documentation.
#
# Please note that once a non-option argument is encountered, all subsequent
# arguments are parsed as non-option arguments.
public__parse() {
	local option_spec && $self "$_:"
	local option
	local args && $self "$_:" && eval "$args"
	local OPTARG
	local OPTIND

	while getopts ":$option_spec" option "${args[@]}"; do
		case $option in
			\?)
				echo "Option is unknown: -$OPTARG" >&2
				exit 1
				;;
			:)
				echo "Option requires a value: -$OPTARG" >&2
				exit 1
				;;
			*)
				if [[ -z ${OPTARG+set} ]]; then
					eval '((arg_opt_'"$option"'++))'
				else
					eval 'arg_opt_'"$option"'+=("$OPTARG")'
				fi
				;;
		esac
	done

	arg_pos=("${args[@]:$((OPTIND - 1))}")
}
