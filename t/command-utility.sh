#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_missing_commands_failure() {
	output=$(new utility lib/utility/CommandUtility 2>&1 || true) && fail_test 1
	[[ $output = "Commands are required." ]] || fail_test 2 "$output"
}

test_invalid_command_failure() {
	output=$(new utility lib/utility/CommandUtility test 2>&1 || true) && fail_test 1
	[[ $output = "Value is not an object reference: test" ]] || fail_test 2 "$output"
}

test_undefined_command_run_failure() {
	new a_command t/lib/ACommand
	new utility lib/utility/CommandUtility "$a_command"
	output=$($utility run b 2>&1 || true) && fail_test 1
	[[ $output = "Command is not defined: b" ]] || fail_test 2 "$output"
}

test_undefined_command_help_failure() {
	new a_command t/lib/ACommand
	new utility lib/utility/CommandUtility "$a_command"
	output=$($utility run b -h 2>&1 || true) && fail_test 1
	[[ $output = "Command is not defined: b" ]] || fail_test 2 "$output"
}

test_implicit_main_help_run() {
	read -r -d "" expected_output <<-EOF
		Usage:
		  command-utility.sh <command> [<argument>...]
		  command-utility.sh <command> (-h | --help)
		  command-utility.sh [-h | --help]

		Commands:
		  a
		  b
	EOF
	new a_command t/lib/ACommand
	new b_command t/lib/BCommand
	new utility lib/utility/CommandUtility "$b_command" "$a_command"
	output=$($utility run) || fail_test 1
	[[ $output = "$expected_output" ]] || fail_test 2 "$output"
}

test_explicit_main_help_run() {
	read -r -d "" expected_output <<-EOF
		Usage:
		  command-utility.sh <command> [<argument>...]
		  command-utility.sh <command> (-h | --help)
		  command-utility.sh [-h | --help]

		Commands:
		  a
		  b
	EOF
	new a_command t/lib/ACommand
	new b_command t/lib/BCommand
	new utility lib/utility/CommandUtility "$b_command" "$a_command"
	output=$($utility run -h) || fail_test 1
	[[ $output = "$expected_output" ]] || fail_test 2 "$output"
	output=$($utility run --help) || fail_test 3
	[[ $output = "$expected_output" ]] || fail_test 4 "$output"
}

test_command_help_run() {
	new a_command t/lib/ACommand
	new b_command t/lib/BCommand
	new utility lib/utility/CommandUtility "$a_command" "$b_command"
	output=$($utility run a -h) || fail_test 1
	[[ $output = "help A" ]] || fail_test 2 "$output"
	output=$($utility run b --help) || fail_test 3
	[[ $output = "help B" ]] || fail_test 4 "$output"
}

test_command_run() {
	read -r -d "" expected_output_a <<-EOF
		execute A
		test
		test
	EOF
	expected_output_b="execute B"
	new a_command t/lib/ACommand
	new b_command t/lib/BCommand
	new utility lib/utility/CommandUtility "$a_command" "$b_command"
	output=$($utility run a test test) || fail_test 1
	[[ $output = "$expected_output_a" ]] || fail_test 2 "$output"
	output=$($utility run b) || fail_test 3
	[[ $output = "$expected_output_b" ]] || fail_test 4 "$output"
}

run_tests "$0"
