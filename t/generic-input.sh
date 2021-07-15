#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_missing_prompt_failure() {
	output=$(new input lib/input/GenericInput 2>&1 || true) && fail_test 1
	[[ $output = "Prompt is required." ]] || fail_test 2 "$output"
}

test_invalid_flag_failure() {
	output=$(new input lib/input/GenericInput Test: "" test 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Flag is not supported: test" ]] || fail_test 2 "$output"
}

test_default_request() {
	expected_stdout=test
	expected_stderr=$(
		echo "${tty_fg_blue}Test:$tty_reset "
		echo "${tty_fg_blue}Test:$tty_reset test"
	)
	new input lib/input/GenericInput Test:
	stdout=$(printf "%s\n" "" test | $input request 2>"$test_data_dir/$test_func") \
		|| fail_test 1
	stderr=$(cat "$test_data_dir/$test_func")
	[[ $stdout = "$expected_stdout" ]] || fail_test 2 "$stdout"
	[[ $stderr = "$expected_stderr" ]] || fail_test 3 "$stderr"
}

test_validated_request() {
	expected_stdout=2
	read -r -d "" expected_stderr <<-EOF
		${tty_fg_blue}Test?$tty_reset $tty_fg_green[1/2/3]$tty_reset 0
		${tty_fg_blue}Test?$tty_reset $tty_fg_green[1/2/3]$tty_reset 2
	EOF
	new input lib/input/GenericInput Test? 1/2/3
	stdout=$(printf "%s\n" 0 2 | $input request 2>"$test_data_dir/$test_func") \
		|| fail_test 1
	stderr=$(cat "$test_data_dir/$test_func")
	[[ $stdout = "$expected_stdout" ]] || fail_test 2 "$stdout"
	[[ $stderr = "$expected_stderr" ]] || fail_test 3 "$stderr"
}

test_optional_request() {
	expected_stdout=
	expected_stderr="${tty_fg_blue}Test:$tty_reset "
	new input lib/input/GenericInput Test: "" optional
	stdout=$(printf "%s\n" "" | $input request 2>"$test_data_dir/$test_func") \
		|| fail_test 1
	stderr=$(cat "$test_data_dir/$test_func")
	[[ $stdout = "$expected_stdout" ]] || fail_test 2 "$stdout"
	[[ $stderr = "$expected_stderr" ]] || fail_test 3 "$stderr"
}

test_secure_request() {
	expected_stdout=test
	expected_stderr="${tty_fg_blue}Test:$tty_reset "
	new input lib/input/GenericInput Test: "" secure
	stdout=$(printf "%s\n" test | $input request 2>"$test_data_dir/$test_func") \
		|| fail_test 1
	stderr=$(cat "$test_data_dir/$test_func")
	[[ $stdout = "$expected_stdout" ]] || fail_test 2 "$stdout"
	[[ $stderr = "$expected_stderr" ]] || fail_test 3 "$stderr"
}

tty_fg_blue=$([[ $TERM =~ ^(dumb)?$ ]] || tput setaf 4)
tty_fg_green=$([[ $TERM =~ ^(dumb)?$ ]] || tput setaf 2)
tty_reset=$([[ $TERM =~ ^(dumb)?$ ]] || tput sgr0)

run_tests "$0"
