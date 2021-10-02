#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_random_path_generation() {
	new dir lib/dir/TmpDir
	dir_1=$($dir print_path)
	new dir lib/dir/TmpDir
	dir_2=$($dir print_path)
	[[ $dir_1 != $dir_2 ]] || fail_test 1 "$dir_1"
}

test_creation_failure() {
	mkdir "$test_data_dir/$test_func"
	TMPDIR="$_"
	new dir lib/dir/TmpDir
	mkdir "$($dir print_path)"
	output=$($dir create 2>&1 || true) && fail_test 1
	[[ $output = *mkdir:* ]] || fail_test 2 "$output"
}

test_creation() {
	mkdir "$test_data_dir/$test_func"
	TMPDIR="$_"
	new dir lib/dir/TmpDir
	$dir create || fail_test 1
	[[ -d $($dir print_path) ]] || fail_test 2
	output=$(ls -ld "$($dir print_path)") || fail_test 3
	perms=${output%% *}
	[[ $perms = drwx------ ]] || fail_test 4 "$perms"
}

test_path_retrieval() {
	new dir lib/dir/TmpDir
	output=$($dir print_path) || fail_test 1
	[[ $output =~ ^/.+ ]] || fail_test 2 "$output"
}

run_tests "$0"
