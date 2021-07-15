#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_missing_commands_failure() {
	output=$(new signal_handler lib/signal/CommandSignalHandler 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Commands are required." ]] || fail_test 2 "$output"
}

test_missing_signals_failure() {
	output=$(new signal_handler lib/signal/CommandSignalHandler test 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Signals are required." ]] || fail_test 2 "$output"
}

test_registration() {
	read -r -d "" expected_output <<-EOF
		trap -- '
		echo '\''test'\''
		exit 0' EXIT
		trap -- '
		exit 0' SIGINT
		test
	EOF
	output=$(
		trap "" EXIT SIGINT
		new signal_handler lib/signal/CommandSignalHandler "echo 'test'" EXIT
		$signal_handler register
		new signal_handler lib/signal/CommandSignalHandler "exit 0" EXIT SIGINT
		$signal_handler register
		trap -p EXIT SIGINT
	) || fail_test 1
	[[ "$output" = "$expected_output" ]] || fail_test 2 "$output"
}

test_multiple_registration_prevention() {
	read -r -d "" expected_output <<-EOF
		trap -- '
		true' EXIT
	EOF
	output=$(
		trap "" EXIT
		new signal_handler lib/signal/CommandSignalHandler true EXIT
		$signal_handler register
		$signal_handler register
		trap -p EXIT
	) || fail_test 1
	[[ "$output" = "$expected_output" ]] || fail_test 2 "$output"
}

run_tests "$0"
