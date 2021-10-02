# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__commands=

#---
# @param $@ `Command` instances representing the commands that should be made
#           available on the command line.
ctor() {
	local param
	local IFS
	local commands

	if [[ $# -eq 0 ]]; then
		echo "Commands are required." >&2
		exit 1
	fi

	for param in "$@"; do
		if ! is_object "$param"; then
			echo "Value is not an object reference: $param" >&2
			exit 1
		fi
	done

	IFS=, commands="$*" && unset IFS

	$self commands="$commands"
}

#---
# See `Utility` type for full documentation.
#
# @param $@ Arguments that were provided on the command line. Operations can be
#           executed as follows:
#
#           - To execute a command, the name of the command must be provided as
#             the first argument. Remaining arguments are passed to the command.
#           - To print usage instructions for a command, `-h` or `--help` must be
#             provided as the first argument for a command.
#           - To print usage instructions for the utility, `-h` or `--help` must
#             be provided as the first argument. Alternatively, executing the
#             utility without arguments has the same effect.
public__run() {
	local help_regex='^(-h|--help)$'
	local utility_help=0
	local command_help=0
	local commands && $self "$_:"
	local command
	local command_name
	local command_list=()

	if [[ $# -eq 0 ]] || [[ $1 =~ $help_regex ]]; then
		utility_help=1
	elif [[ $2 =~ $help_regex ]]; then
		command_help=1
	fi

	IFS=, read -r -a commands <<<"$commands"
	for command in "${commands[@]}"; do
		$command export_name

		if [[ $utility_help -eq 1 ]]; then
			command_list+=("$command_name")
		elif [[ $1 = "$command_name" ]]; then
			if [[ $command_help -eq 1 ]]; then
				$command print_help
			else
				$command execute "${@:2}"
			fi
			return
		fi
	done

	if [[ ${#command_list[@]} -eq 0 ]]; then
		echo "Command is not defined: $1" >&2
		exit 1
	fi

	cat <<-EOF
		Usage:
		  ${0##*/} <command> [<argument>...]
		  ${0##*/} <command> (-h | --help)
		  ${0##*/} [-h | --help]

		Commands:
		$(printf "  %s\n" "${command_list[@]}" | sort)
	EOF
}
