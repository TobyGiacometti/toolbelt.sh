#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_missing_supported_flags_failure() {
	output=$(new flags lib/flags/SupportedFlags 2>&1 || true) && fail_test 1
	[[ $output = "Specification of supported flags is required." ]] \
		|| fail_test 2 "$output"
}

test_invalid_flag_name_failure() {
	output=$(new flags lib/flags/SupportedFlags "test1 " 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Flag name is invalid." ]] || fail_test 2 "$output"
}

test_unsupported_flag_activation_failure() {
	new flags lib/flags/SupportedFlags test1 test2 test3
	output=$($flags activate test1 test4 2>&1 || true) && fail_test 1
	[[ $output = "Flag is not supported: test4" ]] || fail_test 2 "$output"
}

test_activation() {
	new flags lib/flags/SupportedFlags test1 test2 test3
	$flags activate test1 test2
	$flags is_active test1 || fail_test 1
	$flags is_active test2 || fail_test 2
	! $flags is_active test3 || fail_test 3
	$flags activate test3
	$flags is_active test1 || fail_test 4
	$flags is_active test2 || fail_test 5
	$flags is_active test3 || fail_test 6
}

test_unsupported_flag_deactivation_failure() {
	new flags lib/flags/SupportedFlags test1 test2 test3
	output=$($flags deactivate test1 test4 2>&1 || true) && fail_test 1
	[[ $output = "Flag is not supported: test4" ]] || fail_test 2 "$output"
}

test_deactivation() {
	new flags lib/flags/SupportedFlags test1 test2 test3
	$flags activate test1 test1 test2 test3
	$flags deactivate test1 test3
	! $flags is_active test1 || fail_test 1
	$flags is_active test2 || fail_test 2
	! $flags is_active test3 || fail_test 3
}

test_unsupported_flag_state_check_failure() {
	new flags lib/flags/SupportedFlags test1 test2 test3
	output=$($flags is_active test4 2>&1 || true) && fail_test 1
	[[ $output = "Flag is not supported: test4" ]] || fail_test 2 "$output"
}

test_state_check() {
	new flags lib/flags/SupportedFlags test1 test2 test3
	! $flags is_active test1 || fail_test 1
	$flags activate test1 test3
	$flags is_active test1 || fail_test 2
	! $flags is_active test2 || fail_test 3
	$flags is_active test3 || fail_test 4
}

run_tests "$0"
