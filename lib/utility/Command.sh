# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

#---
# Export the command's name.
#
# After the call, the name can be retrieved using the `$command_name` variable.
public__export_name() { :; }

#---
# @stdout Help for the command.
public__print_help() { :; }

#---
# @param $@ Arguments that were provided on the command line (without command
#           name).
public__execute() { :; }
