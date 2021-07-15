#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_invalid_data_path_failure() {
	output=$(new checksum lib/checksum/FileChecksum 2>&1 || true) && fail_test 1
	[[ $output = "Path to file/directory that needs verification is invalid." ]] \
		|| fail_test 2 "$output"
	output=$(new checksum lib/checksum/FileChecksum test 2>&1 || true) && fail_test 3
	[[ $output = "Path to file/directory that needs verification is invalid." ]] \
		|| fail_test 4 "$output"
}

test_inaccessible_data_path_calculation_failure() {
	new checksum lib/checksum/FileChecksum "$test_data_dir/$test_func"
	output=$($checksum calculate 2>&1 || true) && fail_test 1
	[[ $output = "File/directory that needs verification is not accessible." ]] \
		|| fail_test 2 "$output"
}

test_calculation_failure() {
	mkdir "$test_data_dir/$test_func.cksum"
	mkdir "${_%.cksum}"
	new checksum lib/checksum/FileChecksum "$_"
	output=$($checksum calculate 2>&1 || true) && fail_test 1
	[[ $output = *"Is a directory"* ]] || fail_test 2 "$output"
}

test_calculation() {
	checksum_file=$test_data_dir/$test_func/test.cksum
	mkdir "${checksum_file%/*}"
	touch "${checksum_file%.cksum}"
	new checksum lib/checksum/FileChecksum "$_"
	$checksum calculate || fail_test 1
	checksum=$(<"$checksum_file")
	[[ $checksum = *0,e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855,test* ]] \
		|| fail_test 2 "$checksum"
}

test_verification_failure() {
	new checksum lib/checksum/FileChecksum "$test_data_dir/$test_func"
	output=$($checksum verify 2>&1 || true) && fail_test 1
	[[ $output = *"hashdeep -h"* ]] || fail_test 2 "$output"
}

test_verification_when_invalid() {
	data=$test_data_dir/$test_func
	echo 1 >"$data"
	new checksum lib/checksum/FileChecksum "$data"
	$checksum calculate
	echo 2 >"$data"
	output=$(
		$checksum verify
		echo "no exit"
	)
	[[ $output = *"no exit"* ]] || fail_test 1
	[[ $output = *"hashdeep: Audit failed"* ]] || fail_test 2 "$output"
}

test_verification_when_valid() {
	data=$test_data_dir/$test_func
	echo 1 >"$data"
	new checksum lib/checksum/FileChecksum "$data"
	$checksum calculate
	output=$($checksum verify) || fail_test 1
	[[ $output = *"hashdeep: Audit passed"* ]] || fail_test 2 "$output"
}

run_tests "$0"
