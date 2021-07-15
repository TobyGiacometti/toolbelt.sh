#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

test_missing_content_item_addition_failure() {
	new list_output lib/output/OrderedListOutput
	output=$($list_output add_item 2>&1 || true) && fail_test 1
	[[ $output = "Content is required." ]] || fail_test 2 "$output"
}

test_item_addition() {
	tput() {
		[[ $1 = cols ]] && echo 80 || command tput "$@"
	}
	read -r -d "" expected_output <<-EOF
		${tty_standout}1.$tty_reset   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
		${tty_standout}2.$tty_reset   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
		${tty_standout}3.$tty_reset   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
		${tty_standout}4.$tty_reset   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
		${tty_standout}5.$tty_reset   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
		${tty_standout}6.$tty_reset   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
		${tty_standout}7.$tty_reset   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
		${tty_standout}8.$tty_reset   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
		${tty_standout}9.$tty_reset   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
		${tty_standout}10.$tty_reset  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
		     tempor incididunt ut labore et dolore magna aliqua.
	EOF
	new list_output lib/output/OrderedListOutput
	output=$(
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
		$list_output add_item "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
	) || fail_test 1
	[[ $output = "$expected_output" ]] || fail_test 2 "$output"
}

tty_standout=$([[ $TERM =~ ^(dumb)?$ ]] || tput smso)
tty_reset=$([[ $TERM =~ ^(dumb)?$ ]] || tput sgr0)

run_tests "$0"
