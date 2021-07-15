#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_tty_request() {
	read -r -d "" cmd <<-'EOF'
		. libext/soop.sh/soop.sh
		new input lib/input/ConfirmationInput
		$input request
	EOF
	output=$(SHELL=$(which bash) script -q -c "$cmd" /dev/null) || fail_test 1
	[[ $output = "${tty_fg_blue}Press <Enter> to continue$tty_reset$tty_rm_line" ]] \
		|| fail_test 2 "$output"
}

test_non_tty_request() {
	new input lib/input/ConfirmationInput
	output=$($input request 2>&1) || fail_test 1
	[[ -z $output ]] || fail_test 2 "$output"
}

tty_fg_blue=$([[ $TERM =~ ^(dumb)?$ ]] || tput setaf 4)
tty_reset=$([[ $TERM =~ ^(dumb)?$ ]] || tput sgr0)
tty_rm_line=$([[ $TERM =~ ^(dumb)?$ ]] || { tput cr && tput el; })

run_tests "$0"
