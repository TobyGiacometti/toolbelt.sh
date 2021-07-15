# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

# Dependencies:
# - dig

#---
# See `Device` type for full documentation.
public__is_online() {
	local dig_output
	local dig_status
	local grep_status

	# Checking the online status reliably is tricky. Using `ping` is not a good
	# idea because firewalls often block ICMP requests. HTTP requests also don't
	# work well because it can be hard to determine why a request failed (device
	# offline vs. destination not responding). DNS queries for non-existent TLDs
	# work around many of these issues. If no valid response is received to such
	# a basic DNS query, we can assume that the device is offline and that most
	# Internet-related operations won't work. A random string is used as the TLD
	# to avoid cached responses.
	dig_output=$(dig +tries=3 +time=5 $RANDOM.)
	dig_status=$?
	if [[ $dig_status -eq 0 ]]; then
		echo "$dig_output" | grep NXDOMAIN >/dev/null
		grep_status=$?
		if [[ $grep_status -eq 0 ]]; then
			return 0
		elif [[ $grep_status -eq 1 ]]; then
			# The device is connected to the network but the resolver probably
			# does not have access to the Internet. In this case, we assume that
			# the device is offline and that most Internet-related operations
			# won't work.
			return 1
		else
			exit 1
		fi
	elif [[ $dig_status -eq 9 ]]; then
		return 1
	else
		exit 1
	fi
}
