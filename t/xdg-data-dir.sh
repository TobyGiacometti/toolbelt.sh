#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_default_path_generation() {
	new dir lib/dir/XdgDataDir
	output=$($dir print_path)
	[[ $output =~ ^$HOME/.local/share/toolbelt.sh/[0-9]+$ ]] \
		|| fail_test 1 "$output"
}

test_env_path_generation() {
	XDG_DATA_HOME=$test_data_dir/$test_func
	new dir lib/dir/XdgDataDir
	output=$($dir print_path)
	[[ $output =~ ^$XDG_DATA_HOME/toolbelt.sh/[0-9]+$ ]] \
		|| fail_test 1 "$output"
}

test_suffix_path_generation() {
	new dir lib/dir/XdgDataDir "$test_func///"
	output=$($dir print_path)
	[[ $output =~ ^$HOME/.local/share/toolbelt.sh/[0-9]+/$test_func$ ]] \
		|| fail_test 1 "$output"
}

test_creation_failure() {
	XDG_DATA_HOME=$test_data_dir/$test_func
	touch "$XDG_DATA_HOME"
	new dir lib/dir/XdgDataDir
	output=$($dir create 2>&1 || true) && fail_test 1
	[[ $output = *mkdir:* ]] || fail_test 2 "$output"
}

test_creation() {
	XDG_DATA_HOME=$test_data_dir/$test_func
	new dir lib/dir/XdgDataDir
	$dir create || fail_test 1
	[[ -d $($dir print_path) ]] || fail_test 2
}

test_path_retrieval() {
	new dir lib/dir/XdgDataDir "$test_func///"
	output=$($dir print_path) || fail_test 1
	[[ $output =~ ^/.+[^/]$ ]] || fail_test 2 "$output"
}

run_tests "$0"
