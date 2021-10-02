# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__tty_fg_cyan=$([[ $TERM =~ ^(dumb)?$ ]] || tput setaf 6)
ro__tty_reset=$([[ $TERM =~ ^(dumb)?$ ]] || tput sgr0)
# shellcheck disable=SC2015
ro__tty_cols=$([[ $TERM =~ ^(dumb)?$ ]] && echo 80 || tput cols)
ro__title=

#---
# @param $1 Title of the section.
ctor() {
	if [[ -z $1 ]]; then
		echo "Title is required." >&2
		exit 1
	fi

	$self title="$1"
}

#---
# See `SectionOutput` type for full documentation.
public__start() {
	local tty_fg_cyan && $self "$_:"
	local title && $self "$_:"
	local tty_cols && $self "$_:"
	local tty_reset && $self "$_:"

	echo
	echo -n "$tty_fg_cyan# $title "
	eval 'printf "#%.0s" {1..'$((tty_cols - ${#title} - 3))'}'
	echo "$tty_reset"
	echo
}
