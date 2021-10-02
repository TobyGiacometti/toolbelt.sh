#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_invalid_id_failure() {
	output=$(new lock lib/lock/IdLock 2>&1 || true) && fail_test 1
	[[ $output = "ID is invalid." ]] || fail_test 2 "$output"
	output=$(new lock lib/lock/IdLock "test " 2>&1 || true) && fail_test 3
	[[ $output = "ID is invalid." ]] || fail_test 4 "$output"
}

test_invalid_lock_dir_failure() {
	output=$(new lock lib/lock/IdLock test test 2>&1 || true) && fail_test 1
	[[ $output = "Lock directory value is invalid." ]] || fail_test 2 "$output"
}

test_invalid_timeout_acquire_failure() {
	new lock_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new lock lib/lock/IdLock test "$lock_dir"
	output=$($lock acquire test 2>&1 || true) && fail_test 1
	[[ $output = "Timeout value is invalid." ]] || fail_test 2 "$output"
}

test_lock_dir_creation_failure() {
	touch "$test_data_dir/$test_func"
	new lock_dir lib/dir/GenericDir "$_"
	new lock lib/lock/IdLock test "$lock_dir"
	output=$($lock acquire 2>&1 || true) && fail_test 1
	[[ $output = *mkdir:* ]] || fail_test 2 "$output"
}

test_lock_file_creation_failure() {
	mkdir -p "$test_data_dir/$test_func/test"
	new lock_dir lib/dir/GenericDir "${_%/*}"
	new lock lib/lock/IdLock test "$lock_dir"
	output=$($lock acquire 2>&1 || true) && fail_test 1
	[[ $output = *"Is a directory"* ]] || fail_test 2 "$output"
}

test_acquire() {
	new lock_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new lock lib/lock/IdLock test1 "$lock_dir"
	$lock acquire || fail_test 1
	$lock acquire || fail_test 2
	($lock acquire) && fail_test 3
	new lock lib/lock/IdLock test1 "$lock_dir"
	$lock acquire && fail_test 4
	new lock lib/lock/IdLock test2 "$lock_dir"
	$lock acquire || fail_test 5
}

test_release() {
	new lock_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new lock1 lib/lock/IdLock test "$lock_dir"
	new lock2 lib/lock/IdLock test "$lock_dir"
	$lock1 release || fail_test 1
	$lock1 acquire
	$lock1 release || fail_test 2
	$lock2 acquire || fail_test 3
}

run_tests "$0"
