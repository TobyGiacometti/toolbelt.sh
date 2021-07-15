# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

declare self # Fix ShellCheck SC2154.

ro__id=
ro__task_dir=

#---
# @param $1 ID for the task. Please note that only alphanumeric characters and
#           `_` are allowed in task IDs.
# @param $2 `../dir/Dir` instance. If not provided, `../dir/XdgDataDir` is used
#           to store internal task files.
ctor() {
	local task_dir

	if ! [[ $1 =~ ^[A-Za-z0-9_]+$ ]]; then
		echo "ID is invalid." >&2
		exit 1
	elif [[ -n $2 ]] && ! is_object "$2"; then
		echo "Task directory value is invalid." >&2
		exit 1
	fi

	if [[ -z $2 ]]; then
		new task_dir ../dir/XdgDataDir tasks
	else
		task_dir=$2
	fi

	$self id="$1"
	$self task_dir="$task_dir"
}

#---
# See `Task` type for full documentation.
public__create() {
	local task_file
	local task_dir && $self "$_:"

	if ! [[ $1 =~ ^[0-9]+$ ]]; then
		echo "Due date value is invalid." >&2
		exit 1
	fi

	task_file=$($self _print_path)

	if [[ -e $task_file ]]; then
		echo "Task already exists." >&2
		exit 1
	fi

	$task_dir create

	echo $(($(date "+%s") + $1)) >"$task_file" || exit
}

#---
# See `Task` type for full documentation.
public__delete() {
	# shellcheck disable=SC2155
	local task_file=$($self _print_path)

	if ! [[ -e $task_file ]]; then
		echo "Task must be created first." >&2
		exit 1
	fi

	rm "$task_file" || exit
}

#---
# See `Task` type for full documentation.
public__is_created() {
	[[ -e $($self _print_path) ]]
}

#---
# See `Task` type for full documentation.
public__is_due() {
	# shellcheck disable=SC2155
	local task_file=$($self _print_path)
	local due_timestamp

	if ! [[ -e $task_file ]]; then
		echo "Task must be created first." >&2
		exit 1
	fi

	due_timestamp=$(<"$task_file") || exit

	[[ $due_timestamp -le $(date "+%s") ]]
}

#---
# @stdout Path to the task file (without trailing newline).
private__print_path() {
	local task_dir && $self "$_:"
	local id && $self "$_:"

	$task_dir print_path
	echo -n "/$id"
}
