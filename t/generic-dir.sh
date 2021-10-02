#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_invalid_path_failure() {
	output=$(new dir lib/dir/GenericDir 2>&1 || true) && fail_test 1
	[[ $output = "Directory path is invalid." ]] || fail_test 2 "$output"
}

test_creation_failure() {
	touch "$test_data_dir/$test_func"
	new dir lib/dir/GenericDir "$_"
	output=$($dir create 2>&1 || true) && fail_test 1
	[[ $output = *mkdir:* ]] || fail_test 2 "$output"
}

test_creation() {
	new dir lib/dir/GenericDir "$test_data_dir/$test_func"
	$dir create || fail_test 1
	[[ -d $($dir print_path) ]] || fail_test 2
}

test_path_retrieval() {
	new dir lib/dir/GenericDir "$test_data_dir/$test_func///"
	output=$($dir print_path) || fail_test 1
	[[ $output = $test_data_dir/$test_func ]] || fail_test 2 "$output"
}

run_tests "$0"
