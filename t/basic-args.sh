#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_invalid_option_spec_failure() {
	output=$(new args lib/utility/BasicArgs 2>&1 || true) && fail_test 1
	[[ $output = "Option specification is invalid." ]] || fail_test 2 "$output"
	output=$(new args lib/utility/BasicArgs :a 2>&1 || true) && fail_test 3
	[[ $output = "Option specification is invalid." ]] || fail_test 4 "$output"
}

test_unknown_option_parse_failure() {
	new args lib/utility/BasicArgs a -b
	output=$($args parse 2>&1 || true) && fail_test 1
	[[ $output = "Option is unknown: -b" ]] || fail_test 2 "$output"
}

test_missing_option_value_parse_failure() {
	new args lib/utility/BasicArgs a: -a
	output=$($args parse 2>&1 || true) && fail_test 1
	[[ $output = "Option requires a value: -a" ]] || fail_test 2 "$output"
}

test_parse() {
	new args lib/utility/BasicArgs ab: -aa -b test1 -b test2 test1 test2
	$args parse
	unset arg_opt_a arg_opt_b arg_pos
	$args parse || fail_test 1 # Called twice to ensure that getopts state is local.
	[[ $arg_opt_a -eq 2 ]] || fail_test 2 "$arg_opt_a"
	[[ ${arg_opt_b[0]} = test1 && ${arg_opt_b[1]} = test2 ]] \
		|| fail_test 3 "${arg_opt_b[*]}"
	[[ ${arg_pos[0]} = test1 && ${arg_pos[1]} = test2 ]] \
		|| fail_test 4 "${arg_pos[*]}"
}

run_tests "$0"
