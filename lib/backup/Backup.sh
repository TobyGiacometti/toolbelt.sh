# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

#---
# @stdout ID composed of alphanumeric characters and `_` that uniquely identifies
#         the backup on the device.
public__print_id() { :; }

#---
# @param $1	ID for the destination that should be added. The ID is used during
#           various operations to select the desired destination. Please note
#           that only alphanumeric characters and `_` are allowed in destination
#           IDs.
# @param $2 URL or path of the destination.
# @param $3 ID for the backup. The ID is used to differentiate multiple backups
#           in the same destination. Please note that only alphanumeric characters
#           and `_` are allowed in backup IDs.
public__add_destination() { :; }

#---
# @param $1 ID of the destination that should be removed.
public__remove_destination() { :; }

#---
# @stdout IDs of the available destinations separated by `/`. If no destinations
#         are available, nothing is printed.
public__print_destinations() { :; }

#---
# @stdout Path to a file that contains include/exclude patterns for the backup
#         (without trailing newline).
public__print_filter_path() { :; }

#---
# @param $1 ID of the destination where the backup should be stored.
public__run() { :; }

#---
# @param $1 ID of the destination from which the snapshot listing should be
#           retrieved.
# @stdout Snapshot IDs in destination. The output has following format:
#
#         ```
#         id (yyyy-mm-dd hh:mm)
#         id (yyyy-mm-dd hh:mm)
#         ```
#
#         For example:
#
#         ```
#         1 (2021-03-03 03:00)
#         2 (2021-03-03 09:00)
#         ```
#
#         If no backup has been run, nothing is printed.
public__print_snapshots() { :; }

#---
# @param $1 ID of the destination from which the backup should be restored.
# @param $2 ID of the snapshot that should be restored.
# @param $3 Path to the restore directory. If not provided, the backup is restored
#           to the source directory.
# @param... Include/exclude patterns for the restore. If not provided, the full
#           backup is restored.
public__restore() { :; }

#---
# Maintain the backup.
#
# During maintenance, following operations occur:
#
# - Old snapshots are removed if backup retention policies are specified.
# - The integrity of the backup is verified.
#
# @param $1 ID of the destination that should be maintained.
# @param $2 Backup retention policies for the maintenance operation. For example:
#
#           ```sh
#           # - Snapshots older than 7 days: Keep 1 snapshot for each day.
#           # - Snapshots older than 30 days: Keep 1 snapshot every 7 days.
#           # - Snapshots older than 365 days: Keep 1 snapshot every 30 days.
#           # - Snapshots older than 1095 days: Remove all snapshots.
#           $backup maintain example 7:1,30:7,365:30,1095:0
#           ```
#
#           If no backup retention policies are specified, old snapshots are not
#           removed.
# @param... Flags that customize the functionality:
#
#           - `deep`: A more elaborate maintenance process is executed. Deep
#             maintenance should not be executed frequently since it consumes
#             extra resources and can take a very long time.
public__maintain() { :; }
