#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_invalid_log_dir_failure() {
	output=$(new log_file lib/log/TimestampLogFile test 2>&1 || true) && fail_test 1
	[[ $output = "Log directory value is invalid." ]] || fail_test 2 "$output"
}

test_information_recording() {
	read -r -d "" expected_output <<-EOF
		test
		test
	EOF
	new log_dir lib/dir/GenericDir "$test_data_dir/$test_func"
	new log_file lib/log/TimestampLogFile "$log_dir"
	output=$(
		echo test | $log_file record_information
		echo test | $log_file record_information
	) || fail_test 1
	log_files=("$($log_dir print_path)"/*)
	log_file=${log_files[0]}
	log_file_regex='/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}\.log$'
	[[ $log_file =~ $log_file_regex ]] || fail_test 2 "$log_file"
	recording=$(cat "$log_file") || fail_test 3
	[[ $output = $expected_output ]] || fail_test 4 "$output"
	[[ $recording = $expected_output ]] || fail_test 5 "$recording"
}

run_tests "$0"
