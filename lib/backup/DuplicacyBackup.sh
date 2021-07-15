# shellcheck shell=bash

# toolbelt.sh
# https://github.com/TobyGiacometti/toolbelt.sh
# Copyright (c) 2021 Toby Giacometti and contributors
# Apache License 2.0

# Dependencies:
# - Python 3
# - Duplicacy

declare self # Fix ShellCheck SC2154.

ro__source_dir=
ro__metadata_base_dir=

#---
# @param $1 Absolute path to the source directory.
# @param $2 `../dir/Dir` instance. If not provided, `../dir/XdgDataDir` is used
#           to store backup metadata.
ctor() {
	local metadata_base_dir

	if [[ $1 != /* ]]; then
		echo "Source directory path is invalid." >&2
		exit 1
	elif [[ -n $2 ]] && ! is_object "$2"; then
		echo "Metadata directory value is invalid." >&2
		exit 1
	fi

	if [[ -z $2 ]]; then
		new metadata_base_dir ../dir/XdgDataDir backups
	else
		metadata_base_dir=$2
	fi

	$self source_dir="$1"
	$self metadata_base_dir="$metadata_base_dir"
}

#---
# See `Backup` type for full documentation.
#
# The ID cannot be retrieved if the source directory is inaccessible.
public__print_id() {
	local source_dir && $self "$_:"
	local id

	# Ensure that different path specifications (symlinks, `.` and `..`) for the
	# source directory yield the same ID.
	source_dir=$(cd -P -- "$source_dir" &>/dev/null && echo "$PWD") || {
		echo "Source directory is not accessible." >&2
		exit 1
	}

	# ID is converted to lower case to account for case-insensitive filesystems.
	id=${source_dir:1}
	id=${id//[^[:alnum:]]/_}
	id=$(shopt -s extglob && echo "${id//+(_)/_}")
	echo -n "$id" | tr "[:upper:]" "[:lower:]"
}

#---
# See `Backup` type for full documentation.
#
# Check <https://github.com/gilbertchen/duplicacy/wiki/Storage-Backends> for
# supported destination URLs/paths.
#
# @stdin Credentials
# @stdout Credential prompts and status messages.
public__add_destination() {
	local metadata_dir
	local duplicacy_repo_dir
	local source_dir && $self "$_:"
	local metadata_base_dir && $self "$_:"

	if ! [[ $1 =~ ^[A-Za-z0-9_]+$ ]]; then
		echo "Destination ID is invalid." >&2
		exit 1
	elif [[ -z $2 ]]; then
		echo "Destination URL/path is required." >&2
		exit 1
	elif ! [[ $3 =~ ^[A-Za-z0-9_]+$ ]]; then
		echo "Backup ID is invalid." >&2
		exit 1
	fi

	metadata_dir=$($self _print_metadata_path)

	if [[ -z $metadata_dir ]]; then
		echo "Source directory is not accessible." >&2
		exit 1
	fi

	duplicacy_repo_dir=$source_dir
	if [[ $OSTYPE = cygwin ]]; then
		# On Windows, Duplicacy needs a Windows path.
		duplicacy_repo_dir=$(cygpath --windows "$source_dir")
	fi

	$metadata_base_dir create
	mkdir -p "$metadata_dir" || exit

	(
		cd "$metadata_dir" >/dev/null || exit
		if [[ -e .duplicacy/preferences ]]; then
			duplicacy add -e -repository "$duplicacy_repo_dir" "$1" "$3" "$2"
		else
			duplicacy init -e -repository "$duplicacy_repo_dir" \
				-storage-name "$1" "$3" "$2"
			# shellcheck disable=SC2181
			[[ $? -eq 0 ]] || { rm -r "$PWD" && exit 1; }
		fi
	) || exit
}

#---
# See `Backup` type for full documentation.
public__remove_destination() {
	local metadata_dir
	local duplicacy_pref_file

	if [[ -z $1 ]]; then
		echo "Destination ID is required." >&2
		exit 1
	fi

	metadata_dir=$($self _print_metadata_path)

	if [[ -z $metadata_dir ]]; then
		echo "Source directory is not accessible." >&2
		exit 1
	fi

	duplicacy_pref_file=$metadata_dir/.duplicacy/preferences

	if ! $self _destination_exists "$1"; then
		echo "Destination with the specified ID does not exist." >&2
		exit 1
	fi

	# Sharing data with the Python process through environment variables is safer
	# than directly injecting it into the code below.
	duplicacy_pref_file=$duplicacy_pref_file duplicacy_storage_name=$1 python3 <(
		cat <<-EOF
			import json, sys, os
			prefs = [x for x in json.load(sys.stdin) if x['name'] != os.environ['duplicacy_storage_name']]
			with open(os.environ['duplicacy_pref_file'], 'w') as pref_file:
			    json.dump(prefs, pref_file, indent=4)
		EOF
	) <"$duplicacy_pref_file" || exit
}

#---
# See `Backup` type for full documentation.
public__print_destinations() {
	# shellcheck disable=SC2155
	local metadata_dir=$($self _print_metadata_path)

	[[ -n $metadata_dir ]] || return 0

	sed -n \
		's/^[[:space:]]*"name":[[:space:]]*"\(..*\)",*/\1/p' \
		"$metadata_dir/.duplicacy/preferences" 2>/dev/null \
		| paste -s -d / -

	return 0
}

#---
# See `Backup` type for full documentation.
#
# Check <https://github.com/gilbertchen/duplicacy/wiki/Include-Exclude-Patterns>
# for details on how to define include/exclude patterns.
public__print_filter_path() {
	# shellcheck disable=SC2155
	local metadata_dir=$($self _print_metadata_path)

	if [[ -z $metadata_dir ]]; then
		echo "Source directory is not accessible." >&2
		exit 1
	fi

	echo -n "$metadata_dir/.duplicacy/filters"
}

#---
# See `Backup` type for full documentation.
#
# @stdin Credentials
# @stdout Credential prompts and status messages.
public__run() {
	local metadata_dir
	local last_duplicacy_rev

	if [[ -z $1 ]]; then
		echo "Destination ID is required." >&2
		exit 1
	fi

	metadata_dir=$($self _print_metadata_path)

	if [[ -z $metadata_dir ]]; then
		echo "Source directory is not accessible." >&2
		exit 1
	fi

	if ! $self _destination_exists "$1"; then
		echo "Destination with the specified ID does not exist." >&2
		exit 1
	fi

	last_duplicacy_rev=$($self _print_last_duplicacy_rev "$1")

	(
		cd "$metadata_dir" >/dev/null || exit
		SECONDS=0
		duplicacy backup -stats -threads 10 -vss -storage "$1" || exit
		# https://forum.duplicacy.com/t/prune-command-details/1005#corner-cases-when-prune-may-delete-too-much
		if [[ $SECONDS -gt $((3600 * 24 * 7)) || $last_duplicacy_rev -eq 0 ]]; then
			echo
			duplicacy check -storage "$1" -threads 10
		fi
	) || exit
}

#---
# See `Backup` type for full documentation.
public__print_snapshots() {
	local metadata_dir
	local snapshot_line
	local snapshot_output
	local snapshot_regex='revision ([0-9]+) created at ([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2})'

	if [[ -z $1 ]]; then
		echo "Destination ID is required." >&2
		exit 1
	fi

	metadata_dir=$($self _print_metadata_path)

	if [[ -z $metadata_dir ]]; then
		echo "Source directory is not accessible." >&2
		exit 1
	fi

	if ! $self _destination_exists "$1"; then
		echo "Destination with the specified ID does not exist." >&2
		exit 1
	fi

	while IFS= read -r snapshot_line; do
		snapshot_output+=$snapshot_line$'\n'
		if [[ $snapshot_line =~ $snapshot_regex ]]; then
			echo "${BASH_REMATCH[1]} (${BASH_REMATCH[2]})"
		fi
	done < <(
		# The Duplicacy command below is run with the "-background" option to
		# avoid storage password input requests which the user never sees.
		cd "$metadata_dir" >/dev/null || {
			echo -n $?
			exit
		}
		duplicacy -background list -storage "$1"
		echo -n $?
	)

	if [[ "$snapshot_line" -ne 0 ]]; then
		echo -n "$snapshot_output" >&2
		exit "$snapshot_line"
	fi
}

#---
# See `Backup` type for full documentation.
#
# Check <https://github.com/gilbertchen/duplicacy/wiki/Include-Exclude-Patterns>
# for details on how to define include/exclude patterns.
#
# @stdin Credentials
# @stdout Credential prompts and status messages.
public__restore() {
	[[ -n $3 && $3 != /* ]] && set -- "$1" "$2" "$PWD/$3" "${@:4}"

	local metadata_dir
	local restore_metadata_dir
	local metadata_base_dir && $self "$_:"
	local classpath && $self "$_:"
	local status

	if [[ -z $1 ]]; then
		echo "Destination ID is required." >&2
		exit 1
	elif [[ -z $2 ]]; then
		echo "Snapshot ID is required." >&2
		exit 1
	fi

	metadata_dir=$($self _print_metadata_path)

	if [[ -z $metadata_dir ]]; then
		echo "Source directory is not accessible." >&2
		exit 1
	fi

	if [[ -n $3 ]]; then
		mkdir -p "$3" || exit

		restore_metadata_dir=$($self _print_metadata_path "$3")

		if [[ -z $restore_metadata_dir ]]; then
			echo "Restore directory is not accessible." >&2
			exit 1
		fi
	else
		restore_metadata_dir=$metadata_dir
	fi

	if [[ $restore_metadata_dir != "$metadata_dir" ]]; then
		if [[ -e $restore_metadata_dir ]]; then
			echo "The backup cannot be restored to the source directory of another backup." >&2
			exit 1
		fi

		if [[ -e $metadata_dir ]]; then
			# Instead of initializing a new Duplicacy repository, we can copy
			# most of the existing preferences which is much simpler.
			mkdir -p "$restore_metadata_dir/.duplicacy"
			cp -p "$metadata_dir/.duplicacy/preferences" "$_/preferences"
			sed 's/^\([[:space:]]*"repository":[[:space:]]*"\)..*\(",*\)/\1'"${3//\//\\/}"'\2/' \
				"$_" >"$_.tmp"
			mv "$_.tmp" "$_"
		fi

		(
			new backup "$classpath" "$3" "$metadata_base_dir"
			# shellcheck disable=SC2154
			$backup restore "$1" "$2" "" "${@:4}"
		)
		status=$?

		# If a separate restore directory is used, it should not remain a fully
		# configured backup source directory after restoration.
		if [[ -e $restore_metadata_dir ]]; then
			rm -r "$restore_metadata_dir"
		fi

		[[ $status -eq 0 ]] && return || exit
	fi

	if ! $self _destination_exists "$1"; then
		echo "Destination with the specified ID does not exist." >&2
		exit 1
	fi

	(
		cd "$metadata_dir" >/dev/null || exit
		duplicacy restore -r "$2" -overwrite -delete -stats -threads 10 -persist \
			-storage "$1" -- "${@:4}"
	) || exit
}

#---
# See `Backup` type for full documentation.
#
# @stdin Credentials
# @stdout Credential prompts and status messages.
public__maintain() {
	local flags
	local metadata_dir
	local retention_policy
	local duplicacy_keep_opts=()

	if [[ -z $1 ]]; then
		echo "Destination ID is required." >&2
		exit 1
	elif [[ -n $2 && ! $2, =~ ^([0-9]+:[0-9]+,)+$ ]]; then
		echo "Backup retention policies are invalid." >&2
		exit 1
	fi

	new flags ../flags/SupportedFlags deep
	$flags activate "${@:3}"

	metadata_dir=$($self _print_metadata_path)

	if [[ -z $metadata_dir ]]; then
		echo "Source directory is not accessible." >&2
		exit 1
	fi

	if ! $self _destination_exists "$1"; then
		echo "Destination with the specified ID does not exist." >&2
		exit 1
	fi

	for retention_policy in $(echo "${2//,/$'\n'}" | sort -n -r -); do
		IFS=: read -r -a retention_policy <<<"$retention_policy"
		duplicacy_keep_opts+=(-keep "${retention_policy[1]}:${retention_policy[0]}")
	done

	(
		cd "$metadata_dir" >/dev/null || exit
		if [[ ${#duplicacy_keep_opts} -gt 0 ]]; then
			duplicacy prune "${duplicacy_keep_opts[@]}" -storage "$1" -threads 10 || exit
			echo
		fi
		duplicacy check -storage "$1" -threads 10 || exit
		if $flags is_active deep; then
			echo
			# An integrity problem with a chunk that is not referenced by the
			# last revision can usually not be fixed (the files in question have
			# changed or have been deleted). We therefore only check the last
			# revision.
			duplicacy check -r "$($self _print_last_duplicacy_rev "$1")" \
				-files -storage "$1" -threads 10 -persist
		fi
	) || exit
}

#---
# @param $1 Path to the source directory for which the metadata directory path
#           should be printed. If not provided, the source directory is retrieved
#           from the `source_dir` field.
# @stdout Path to the metadata directory (without trailing slash and newline).
#         If the source directory is not accessible, nothing is printed.
private__print_metadata_path() {
	local backup=$self
	local classpath && $self "$_:"
	local metadata_base_dir && $self "$_:"
	local backup_id

	[[ -n $1 ]] && new backup "$classpath" "$1" "$metadata_base_dir"
	backup_id=$($backup print_id 2>/dev/null) || return 0

	$metadata_base_dir print_path
	echo -n "/$backup_id"
}

#---
# @param $1 ID of the destination that should be checked.
private__destination_exists() {
	local metadata_dir

	if [[ -z $1 ]]; then
		echo "Destination ID is required." >&2
		exit 1
	fi

	metadata_dir=$($self _print_metadata_path)

	if [[ -z $metadata_dir ]]; then
		return 1
	fi

	grep --quiet '"name": "'"$1"'",' "$metadata_dir/.duplicacy/preferences" 2>/dev/null
}

#---
# @param $1 Name of the Duplicacy storage from which the number of the last
#           revision should be retrieved.
# @stdout Last Duplicacy revision number in storage. If the specified storage
#         cannot be accessed or no revision has been stored, `0` is printed.
private__print_last_duplicacy_rev() {
	local metadata_dir

	if [[ -z $1 ]]; then
		echo "Duplicacy storage name is required." >&2
		exit 1
	fi

	metadata_dir=$($self _print_metadata_path)

	[[ -n $metadata_dir ]] || { echo 0 && return; }

	(
		# The Duplicacy command below is run with the "-background" option to
		# avoid storage password input requests which are printed to STDOUT and
		# swallowed by any command substitutions.
		cd "$metadata_dir" &>/dev/null || exit
		duplicacy_cmd=(duplicacy -background cat -storage "$1" toolbelt.sh.$RANDOM)
		rev_regex='revision[[:space:]]([0-9]+)$'
		[[ $("${duplicacy_cmd[@]}" 2>&1) =~ $rev_regex ]] || exit
		echo "${BASH_REMATCH[1]}"
	) || echo 0
}
