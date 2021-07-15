# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__tty_standout=$([[ $TERM =~ ^(dumb)?$ ]] || tput smso)
ro__tty_reset=$([[ $TERM =~ ^(dumb)?$ ]] || tput sgr0)
# shellcheck disable=SC2015
ro__tty_cols=$([[ $TERM =~ ^(dumb)?$ ]] && echo 80 || tput cols)
ro__item_padding=5
rw__item_counter=1

#---
# See `ListOutput` type for full documentation.
public__add_item() {
	local tty_standout && $self "$_:"
	local item_counter && $self "$_:"
	local tty_reset && $self "$_:"
	local item_padding && $self "$_:"
	local line
	local line_num=1
	local tty_cols && $self "$_:"

	if [[ -z $1 ]]; then
		echo "Content is required." >&2
		exit 1
	fi

	echo -n "$tty_standout$item_counter.$tty_reset"
	printf "%-$((item_padding - ${#item_counter} - 1))s"
	# Content that is wider than the terminal should wrap with correct indentation.
	while IFS= read -r line; do
		[[ $line_num -gt 1 ]] && printf "%-${item_padding}s"
		printf "%s\n" "${line% }"
		((line_num++))
	done < <(printf "%s\n" "$1" | fold -w $((tty_cols - item_padding)) -s)

	((item_counter++))
	$self item_counter="$item_counter"
}
