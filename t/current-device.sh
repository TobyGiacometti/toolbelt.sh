#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_dig_online_check_failure() {
	dig() {
		echo "An error occurred." >&2
		return 1
	}
	new device lib/device/CurrentDevice
	output=$($device is_online 2>&1 || true) && fail_test 1
	[[ $output = "An error occurred." ]] || fail_test 2 "$output"
}

test_grep_online_check_failure() {
	dig() {
		:
	}
	grep() {
		read # Wait for input to avoid broken pipe.
		echo "An error occurred." >&2
		return 2
	}
	new device lib/device/CurrentDevice
	output=$($device is_online 2>&1 || true) && fail_test 1
	[[ $output = "An error occurred." ]] || fail_test 2 "$output"
}

test_online_check_when_online() {
	dig() {
		echo NXDOMAIN
	}
	new device lib/device/CurrentDevice
	$device is_online || fail_test 1
}

test_online_check_when_reply_invalid() {
	dig() {
		echo NOERROR
	}
	new device lib/device/CurrentDevice
	! $device is_online || fail_test 1
}

test_online_check_when_offline() {
	dig() {
		return 9
	}
	new device lib/device/CurrentDevice
	! $device is_online || fail_test 1
}

run_tests "$0"
