#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

teardown_test() {
	if [[ ${task_dir+set} && -e $($task_dir print_path) ]]; then
		chmod +w "$($task_dir print_path)"
	fi
}

test_invalid_id_failure() {
	output=$(new task lib/task/IdTask 2>&1 || true) && fail_test 1
	[[ $output = "ID is invalid." ]] || fail_test 2 "$output"
	output=$(new task lib/task/IdTask "test " 2>&1 || true) && fail_test 3
	[[ $output = "ID is invalid." ]] || fail_test 4 "$output"
}

test_invalid_task_dir_failure() {
	output=$(new task lib/task/IdTask test test 2>&1 || true) && fail_test 1
	[[ $output = "Task directory value is invalid." ]] || fail_test 2 "$output"
}

test_invalid_due_date_creation_failure() {
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	output=$($task create 2>&1 || true) && fail_test 1
	[[ $output = "Due date value is invalid." ]] || fail_test 2 "$output"
	output=$($task create test 2>&1 || true) && fail_test 3
	[[ $output = "Due date value is invalid." ]] || fail_test 4 "$output"
}

test_already_created_failure() {
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	$task create 15
	output=$($task create 15 2>&1 || true) && fail_test 1
	[[ $output = "Task already exists." ]] || fail_test 2 "$output"
}

test_task_dir_creation_failure() {
	touch "$test_data_dir/$test_func"
	new task_dir lib/dir/GenericDir "$_"
	new task lib/task/IdTask test "$task_dir"
	output=$($task create 15 2>&1 || true) && fail_test 1
	[[ $output = *mkdir:* ]] || fail_test 2 "$output"
}

test_creation_failure() {
	mkdir -p "$test_data_dir/$test_func"
	chmod -w "$_"
	new task_dir lib/dir/GenericDir "$_"
	new task lib/task/IdTask test "$task_dir"
	output=$($task create 15 2>&1 || true) && fail_test 1
	[[ $output = *"Permission denied"* ]] || fail_test 2 "$output"
}

test_creation() {
	date() {
		[[ $1 = "+%s" ]] && echo 15 || date "$@"
	}
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	$task create 15 || fail_test 1
	due_timestamp=$(cat "$($task_dir print_path)/test") || fail_test 2
	[[ $due_timestamp -eq 30 ]] || fail_test 3 "$due_timestamp"
}

test_not_created_deletion_failure() {
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	output=$($task delete 2>&1 || true) && fail_test 1
	[[ $output = "Task must be created first." ]] || fail_test 2 "$output"
}

test_deletion_failure() {
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	$task create 15
	chmod -w "$($task_dir print_path)"
	output=$($task delete 2>&1 || true) && fail_test 1
	[[ $output = *rm:* ]] || fail_test 2 "$output"
}

test_deletion() {
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	$task create 15
	$task delete || fail_test 1
	! $task is_created || fail_test 2
}

test_existence_check() {
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	! $task is_created || fail_test 1
	$task create 15
	$task is_created || fail_test 2
}

test_not_created_due_check_failure() {
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	output=$($task is_due 2>&1 || true) && fail_test 1
	[[ $output = "Task must be created first." ]] || fail_test 2 "$output"
}

test_due_check_failure() {
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	$task create 15
	chmod -r "$($task_dir print_path)/test"
	output=$($task is_due 2>&1 || true) && fail_test 1
	[[ $output = *"Permission denied"* ]] || fail_test 2 "$output"
}

test_due_check() {
	new task_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new task lib/task/IdTask test "$task_dir"
	$task create 15
	! $task is_due || fail_test 1
	$task delete
	$task create 0
	$task is_due || fail_test 2
}

run_tests "$0"
