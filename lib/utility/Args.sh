# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

#---
# Parse the command-line arguments.
#
# After the call, special variables can be accessed to conveniently work with
# the arguments:
#
# - Option arguments are represented by variables whose name starts with `arg_opt_`
#   followed by the option name. If an argument is a boolean option, the variable
#   contains the number of times that the option was specified. If an argument is
#   an option with a value, the variable contains an array of values that were
#   provided.
# - All remaining arguments are stored in an indexed array named `arg_pos`.
#
# For example:
#
# ```sh
# # -t example -t book -vvv /path/to/file /path/to/another/file
# $args parse
# echo "${arg_opt_t[0]}" # example
# echo "${arg_opt_t[1]}" # book
# echo "$arg_opt_v" # 3
# echo "${arg_pos[0]}" # /path/to/file
# echo "${arg_pos[1]}" # /path/to/another/file
# ```
public__parse() { :; }
