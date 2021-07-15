# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

#---
# Acquire the lock.
#
# Please note that the lock is bound to an object instance. This method only
# blocks or returns a non-zero status code when called using another object
# instance with the same identity. Calling this method using an object instance
# that already holds a lock always succeedes.
#
# Keep in mind that locks are automatically released when the current process
# terminates.
#
# @param $1 Number of seconds to wait for the lock to be released. Defaults to
#           `0` if not provided.
public__acquire() { :; }

public__release() { :; }
