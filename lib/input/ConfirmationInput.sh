# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__tty_fg_blue=$([[ $TERM =~ ^(dumb)?$ ]] || tput setaf 4)
ro__tty_reset=$([[ $TERM =~ ^(dumb)?$ ]] || tput sgr0)
ro__tty_rm_line=$([[ $TERM =~ ^(dumb)?$ ]] || { tput cr && tput el; })

#---
# See `Input` type for full documentation.
#
# Instead of recording input, this implementation simply waits for the Enter key
# to be pressed.
#
# The prompt is only printed if STDERR is connected to a terminal.
public__request() {
	local tty_fg_blue && $self "$_:"
	local tty_reset && $self "$_:"
	local tty_rm_line && $self "$_:"

	# Since the prompt should be removed from the screen once confirmation is
	# received, it makes sense for it to only appear on the terminal.
	[[ -t 2 ]] && echo -n "${tty_fg_blue}Press <Enter> to continue$tty_reset" >&2
	# shellcheck disable=SC2162
	read -s
	[[ -t 2 ]] && echo -n "$tty_rm_line" >&2

	return 0
}
