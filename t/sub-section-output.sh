#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_missing_title_failure() {
	output=$(new section_output lib/output/SubSectionOutput 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Title is required." ]] || fail_test 2 "$output"
}

test_invalid_position_failure() {
	output=$(new section_output lib/output/SubSectionOutput Test 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Position is invalid." ]] || fail_test 2 "$output"
	output=$(new section_output lib/output/SubSectionOutput Test test 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Position is invalid." ]] || fail_test 2 "$output"
}

test_initial_start() {
	tput() {
		[[ $1 = cols ]] && echo 80 || command tput "$@"
	}
	read -r -d "" expected_output <<-EOF
		test
		$tty_fg_cyan- Test -------------------------------------------------------------------------$tty_reset

		test
	EOF
	new section_output lib/output/SubSectionOutput Test initial
	output=$(echo test && $section_output start && echo test) || fail_test 1
	[[ $output = "$expected_output" ]] || fail_test 2 "$output"
}

test_noninitial_start() {
	tput() {
		[[ $1 = cols ]] && echo 80 || command tput "$@"
	}
	read -r -d "" expected_output <<-EOF
		test

		$tty_fg_cyan- Test -------------------------------------------------------------------------$tty_reset

		test
	EOF
	new section_output lib/output/SubSectionOutput Test noninitial
	output=$(echo test && $section_output start && echo test) || fail_test 1
	[[ $output = "$expected_output" ]] || fail_test 2 "$output"
}

tty_fg_cyan=$([[ $TERM =~ ^(dumb)?$ ]] || tput setaf 6)
tty_reset=$([[ $TERM =~ ^(dumb)?$ ]] || tput sgr0)

run_tests "$0"
