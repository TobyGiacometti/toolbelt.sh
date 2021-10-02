#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_invalid_path_failure() {
	output=$(new log_file lib/log/GenericLogFile 2>&1 || true) && fail_test 1
	[[ $output = "Path is invalid." ]] || fail_test 2 "$output"
	output=$(new log_file lib/log/GenericLogFile test 2>&1 || true) && fail_test 3
	[[ $output = "Path is invalid." ]] || fail_test 4 "$output"
}

test_information_recording_failure() {
	new log_file lib/log/GenericLogFile /$RANDOM/$RANDOM/$RANDOM
	output=$($log_file record_information < <(echo test) 2>&1 || true) && fail_test 1
	[[ $output = *tee:* ]] || fail_test 2 "$output"
}

test_information_recording() {
	log_file_path=$test_data_dir/$test_func
	read -r -d "" expected_output <<-EOF
		test
		test
	EOF
	new log_file lib/log/GenericLogFile "$log_file_path"
	output=$(
		echo test | $log_file record_information
		echo test | $log_file record_information
	) || fail_test 1
	recording=$(cat "$log_file_path") || fail_test 2
	[[ $output = $expected_output ]] || fail_test 3 "$output"
	[[ $recording = $expected_output ]] || fail_test 4 "$recording"
}

run_tests "$0"
