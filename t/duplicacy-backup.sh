#!/usr/bin/env bash

. libext/test.sh/test.sh
. libext/soop.sh/soop.sh

setup_test() {
	local random=$RANDOM
	destination_pw=testtest
	new metadata_base_dir lib/dir/GenericDir "$test_data_dir/$test_func/metadata"
	source_dir=/tmp/Backup-Source--$random
	destination_dir=$test_data_dir/$test_func/destination
	metadata_dir=$(
		$metadata_base_dir print_path
		echo "/tmp_backup_source_$random"
	)
	mkdir -p "$metadata_dir" "$source_dir" "$destination_dir"
}

teardown_test() {
	rm -rf "$source_dir"
}

test_invalid_source_dir_failure() {
	output=$(new backup lib/backup/DuplicacyBackup 2>&1 || true) && fail_test 1
	[[ $output = "Source directory path is invalid." ]] || fail_test 2 "$output"
	output=$(new backup lib/backup/DuplicacyBackup test 2>&1 || true) && fail_test 3
	[[ $output = "Source directory path is invalid." ]] || fail_test 4 "$output"
}

test_invalid_metadata_dir_failure() {
	output=$(new backup lib/backup/DuplicacyBackup /test test 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Metadata directory value is invalid." ]] || fail_test 2 "$output"
}

test_inaccessible_source_dir_id_retrieval_failure() {
	rm -r "$source_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup print_id 2>&1 || true) && fail_test 1
	[[ $output = "Source directory is not accessible." ]] || fail_test 2 "$output"
}

test_id_retrieval() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup print_id) || fail_test 1
	[[ $output = ${metadata_dir##*/} ]] || fail_test 2 "$output"
}

test_invalid_destination_id_destination_addition_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup add_destination 2>&1 || true) && fail_test 1
	[[ $output = "Destination ID is invalid." ]] || fail_test 2 "$output"
	output=$($backup add_destination test-id 2>&1 || true) && fail_test 3
	[[ $output = "Destination ID is invalid." ]] || fail_test 4 "$output"
}

test_missing_destination_destination_addition_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup add_destination test 2>&1 || true) && fail_test 1
	[[ $output = "Destination URL/path is required." ]] || fail_test 2 "$output"
}

test_invalid_backup_id_destination_addition_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup add_destination test "$destination_dir" 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Backup ID is invalid." ]] || fail_test 2 "$output"
	output=$($backup add_destination test "$destination_dir" test-id 2>&1 || true) \
		&& fail_test 3
	[[ $output = "Backup ID is invalid." ]] || fail_test 4 "$output"
}

test_inaccessible_source_dir_destination_addition_failure() {
	rm -r "$source_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup add_destination test "$destination_dir" test 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Source directory is not accessible." ]] || fail_test 2 "$output"
}

test_metadata_dir_creation_failure() {
	rm -r "$metadata_dir"
	touch "$metadata_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup add_destination test "$destination_dir" test 2>&1 || true) \
		&& fail_test 1
	[[ $output = *mkdir:* ]] || fail_test 2 "$output"
}

test_destination_addition_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup add_destination test "gcs://test/test" test 2>&1 || true) \
		&& fail_test 1
	[[ $output = "Enter the path of the Google"*"gcs://test/test: open : no such file or directory" ]] \
		|| fail_test 2 "$output"
	[[ ! -d $metadata_dir ]] || fail_test 3
}

test_initial_destination_addition() {
	read -r -d "" expected_preferences <<-EOF
		[
		    {
		        "name": "test",
		        "id": "backup",
		        "repository": "$source_dir",
		        "storage": "$destination_dir",
		        "encrypted": true,
		        "no_backup": false,
		        "no_restore": false,
		        "no_save_password": false,
		        "nobackup_file": "",
		        "keys": null,
		        "filters": "",
		        "exclude_by_attribute": false
		    }
		]
	EOF
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" backup \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw" || fail_test 1
	preferences=$(<"$metadata_dir/.duplicacy/preferences")
	[[ "$preferences" = "$expected_preferences" ]] || fail_test 2 "$preferences"
}

test_additional_destination_addition() {
	read -r -d "" expected_preferences <<-EOF
		[
		    {
		        "name": "test1",
		        "id": "backup",
		        "repository": "$source_dir",
		        "storage": "$destination_dir",
		        "encrypted": true,
		        "no_backup": false,
		        "no_restore": false,
		        "no_save_password": false,
		        "nobackup_file": "",
		        "keys": null,
		        "filters": "",
		        "exclude_by_attribute": false
		    },
		    {
		        "name": "test2",
		        "id": "backup",
		        "repository": "$source_dir",
		        "storage": "$destination_dir",
		        "encrypted": true,
		        "no_backup": false,
		        "no_restore": false,
		        "no_save_password": false,
		        "nobackup_file": "",
		        "keys": null,
		        "filters": "",
		        "exclude_by_attribute": false
		    }
		]
	EOF
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test1 "$destination_dir" backup \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	$backup add_destination test2 "$destination_dir" backup \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw" || fail_test 1
	preferences=$(<"$metadata_dir/.duplicacy/preferences")
	[[ "$preferences" = "$expected_preferences" ]] || fail_test 2 "$preferences"
}

test_windows_destination_addition() {
	cygpath() {
		echo 'C:\test'
	}
	OSTYPE=cygwin
	read -r -d "" expected_preferences <<-EOF
		[
		    {
		        "name": "test",
		        "id": "backup",
		        "repository": "C:\\\\test",
		        "storage": "$destination_dir",
		        "encrypted": true,
		        "no_backup": false,
		        "no_restore": false,
		        "no_save_password": false,
		        "nobackup_file": "",
		        "keys": null,
		        "filters": "",
		        "exclude_by_attribute": false
		    }
		]
	EOF
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" backup \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw" || fail_test 1
	preferences=$(<"$metadata_dir/.duplicacy/preferences")
	[[ "$preferences" = "$expected_preferences" ]] || fail_test 2 "$preferences"
}

test_missing_destination_id_destination_removal_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup remove_destination 2>&1 || true) && fail_test 1
	[[ $output = "Destination ID is required." ]] || fail_test 2 "$output"
}

test_inaccessible_source_dir_destination_removal_failure() {
	rm -r "$source_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup remove_destination test 2>&1 || true) && fail_test 1
	[[ $output = "Source directory is not accessible." ]] || fail_test 2 "$output"
}

test_nonexistent_destination_destination_removal_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup remove_destination test 2>&1 || true) && fail_test 1
	[[ $output = "Destination with the specified ID does not exist." ]] \
		|| fail_test 2 "$output"
}

test_destination_removal_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	chmod -w "$metadata_dir/.duplicacy/preferences"
	output=$($backup remove_destination test 2>&1 || true) && fail_test 1
	[[ $output = *Traceback* ]] || fail_test 2 "$output"
}

test_destination_removal() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	output=$($backup print_destinations)
	[[ $output = test ]] || fail_test 1 "$output"
	$backup remove_destination test || fail_test 2
	output=$($backup print_destinations)
	[[ -z $output ]] || fail_test 3 "$output"
}

test_destination_retrieval() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup print_destinations 2>&1) || fail_test 1
	[[ -z $output ]] || fail_test 2 "$output"
	$backup add_destination test1 "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	$backup add_destination test2 "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	$backup add_destination test3 "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	output=$($backup print_destinations) || fail_test 3
	[[ $output = test1/test2/test3 ]] || fail_test 4 "$output"
}

test_inaccessible_source_dir_filter_path_retrieval_failure() {
	rm -r "$source_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup print_filter_path 2>&1 || true) && fail_test 1
	[[ $output = "Source directory is not accessible." ]] || fail_test 2 "$output"
}

test_filter_path_retrieval() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup print_filter_path) || fail_test 1
	[[ $output = $metadata_dir/.duplicacy/filters ]] || fail_test 2 "$output"
}

test_missing_destination_id_run_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup run 2>&1 || true) && fail_test 1
	[[ $output = "Destination ID is required." ]] || fail_test 2 "$output"
}

test_inaccessible_source_dir_run_failure() {
	rm -r "$source_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup run test 2>&1 || true) && fail_test 1
	[[ $output = "Source directory is not accessible." ]] || fail_test 2 "$output"
}

test_nonexistent_destination_run_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup run test 2>&1 || true) && fail_test 1
	[[ $output = "Destination with the specified ID does not exist." ]] \
		|| fail_test 2 "$output"
}

test_run_backup_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value test >/dev/null
	cd "$OLDPWD"
	output=$($backup run test 2>&1 || true) && fail_test 1
	[[ $output = *"message authentication failed"* ]] || fail_test 2 "$output"
}

test_run_check_failure() {
	duplicacy() {
		if [[ $1 = check ]]; then
			echo error >&2
			return 1
		else
			command duplicacy "$@"
		fi
	}
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	echo test >"$source_dir/test"
	output=$($backup run test 2>&1 || true) && fail_test 1
	[[ $output = *error ]] || fail_test 2 "$output"
}

test_initial_run() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	echo test >"$source_dir/test"
	output=$($backup run test) || fail_test 1
	[[ $output = *"Backup for $source_dir at revision 1 completed"* ]] \
		|| fail_test 2 "$output"
	[[ $output = *"All chunks referenced by snapshot test at revision 1 exist"* ]] \
		|| fail_test 3 "$output"
}

test_long_run() {
	duplicacy() {
		SECONDS=$((3600 * 24 * 8))
		command duplicacy "$@"
	}
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	echo test >"$source_dir/test"
	$backup run test >/dev/null
	output=$($backup run test) || fail_test 2
	[[ $output = *"Backup for $source_dir at revision 2 completed"* ]] \
		|| fail_test 2 "$output"
	[[ $output = *"All chunks referenced by snapshot test at revision 2 exist"* ]] \
		|| fail_test 3 "$output"
}

test_common_run() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	echo test >"$source_dir/test"
	$backup run test >/dev/null
	output=$($backup run test) || fail_test 2
	[[ $output = *"Backup for $source_dir at revision 2 completed"* ]] \
		|| fail_test 2 "$output"
	[[ $output != *"All chunks referenced by snapshot test at revision 2 exist"* ]] \
		|| fail_test 3 "$output"
}

test_missing_destination_id_snapshot_retrieval_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup print_snapshots 2>&1 || true) && fail_test 1
	[[ $output = "Destination ID is required." ]] || fail_test 2 "$output"
}

test_inaccessible_source_dir_snapshot_retrieval_failure() {
	rm -r "$source_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup print_snapshots test 2>&1 || true) && fail_test 1
	[[ $output = "Source directory is not accessible." ]] || fail_test 2 "$output"
}

test_nonexistent_destination_snapshot_retrieval_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup print_snapshots test 2>&1 || true) && fail_test 1
	[[ $output = "Destination with the specified ID does not exist." ]] \
		|| fail_test 2 "$output"
}

test_snapshot_retrieval_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value test >/dev/null
	cd "$OLDPWD"
	output=$($backup print_snapshots test 2>&1 || true) && fail_test 1
	[[ $output = *"message authentication failed" ]] \
		|| fail_test 2 "$output"
}

test_nonexistent_snapshot_retrieval() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	output=$($backup print_snapshots test) || fail_test 1
	[[ -z $output ]] || fail_test 2 "$output"
}

test_snapshot_retrieval() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	echo test >"$source_dir/test"
	$backup run test >/dev/null
	$backup run test >/dev/null
	output=$($backup print_snapshots test) || fail_test 1
	[[ $output = "1 ("*-*-*" "*:*")"$'\n'"2 ("*-*-*" "*:*")" ]] \
		|| fail_test 2 "$output"
}

test_missing_destination_id_restore_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup restore 2>&1 || true) && fail_test 1
	[[ $output = "Destination ID is required." ]] || fail_test 2 "$output"
}

test_missing_snapshot_id_restore_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup restore test 2>&1 || true) && fail_test 1
	[[ $output = "Snapshot ID is required." ]] || fail_test 2 "$output"
}

test_inaccessible_source_dir_restore_failure() {
	rm -r "$source_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup restore test 1 2>&1 || true) && fail_test 1
	[[ $output = "Source directory is not accessible." ]] || fail_test 2 "$output"
}

test_restore_dir_creation_failure() {
	restore_dir=$test_data_dir/$test_func/restore
	mkdir -p "${restore_dir%/*}"
	touch "$restore_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup restore test 1 "$restore_dir" 2>&1 || true) && fail_test 1
	[[ $output = *mkdir:* ]] || fail_test 2 "$output"
}

test_inaccessible_restore_dir_restore_failure() {
	restore_dir=$test_data_dir/$test_func/restore
	mkdir -p "$restore_dir"
	chmod -x "$restore_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup restore test 1 "$restore_dir" 2>&1 || true) && fail_test 1
	[[ $output = "Restore directory is not accessible." ]] || fail_test 2 "$output"
}

test_other_source_dir_restore_failure() {
	restore_dir=$test_data_dir/$test_func/restore
	mkdir -p "$restore_dir"
	new backup lib/backup/DuplicacyBackup "$restore_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup restore test 1 "$restore_dir" 2>&1 || true) && fail_test 1
	[[ $output = "The backup cannot be restored to the source directory of another backup." ]] \
		|| fail_test 2 "$output"
}

test_nonexistent_destination_restore_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup restore test 1 2>&1 || true) && fail_test 1
	[[ $output = "Destination with the specified ID does not exist." ]] \
		|| fail_test 2 "$output"
}

test_custom_restore_dir_restore_failure() {
	restore_dir=$test_data_dir/$test_func/restore
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	output=$($backup restore test 1 "$restore_dir" 2>&1 || true) && fail_test 1
	[[ $output = *"Snapshot test at revision 1 does not exist"* ]] \
		|| fail_test 2 "$output"
	output=$($backup restore test 1 "$restore_dir" 2>&1 || true) && fail_test 3
	[[ $output = *"Snapshot test at revision 1 does not exist"* ]] \
		|| fail_test 4 "$output"
}

test_restore_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	output=$($backup restore test 1 2>&1 || true) && fail_test 1
	[[ $output = *"Snapshot test at revision 1 does not exist"* ]] \
		|| fail_test 2 "$output"
}

test_custom_restore_dir_restore() {
	restore_dir=$test_data_dir/$test_func/restore
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	echo 1 >"$source_dir/test"
	$backup run test >/dev/null
	echo 15 >"$source_dir/test"
	cd "${restore_dir%/*}"
	$backup restore test 1 "${restore_dir##*/}" >/dev/null || fail_test 1
	$backup restore test 1 "${restore_dir##*/}" >/dev/null || fail_test 2
	source_content=$(cat "$source_dir/test")
	[[ $source_content = 15 ]] || fail_test 3 "$source_content"
	restore_content=$(cat "$restore_dir/test")
	[[ $restore_content = 1 ]] || fail_test 4 "$restore_content"
}

test_filtered_restore() {
	restore_dir=$test_data_dir/$test_func/restore
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	echo test >"$source_dir/test1"
	echo test >"$source_dir/test2"
	echo test >"$source_dir/test3"
	$backup run test >/dev/null
	$backup restore test 1 "$restore_dir" +test1 +test3 >/dev/null || fail_test 1
	[[ -e $restore_dir/test1 ]] || fail_test 2
	[[ ! -e $restore_dir/test2 ]] || fail_test 3
	[[ -e $restore_dir/test3 ]] || fail_test 4
}

test_restore() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	echo 1 >"$source_dir/test"
	$backup run test >/dev/null
	echo 15 >"$source_dir/test"
	$backup run test >/dev/null
	source_content=$(cat "$source_dir/test")
	[[ $source_content = 15 ]] || fail_test 1 "$source_content"
	$backup restore test 1 >/dev/null || fail_test 2
	restore_content=$(cat "$source_dir/test")
	[[ $restore_content = 1 ]] || fail_test 3 "$restore_content"
}

test_missing_destination_id_maintenance_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup maintain 2>&1 || true) && fail_test 1
	[[ $output = "Destination ID is required." ]] || fail_test 2 "$output"
}

test_invalid_retention_policies_maintenance_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup maintain test 15 2>&1 || true) && fail_test 1
	[[ $output = "Backup retention policies are invalid." ]] || fail_test 2 "$output"
	output=$($backup maintain test 15:15, 2>&1 || true) && fail_test 3
	[[ $output = "Backup retention policies are invalid." ]] || fail_test 4 "$output"
	output=$($backup maintain test 15:15,15: 2>&1 || true) && fail_test 5
	[[ $output = "Backup retention policies are invalid." ]] || fail_test 6 "$output"
	output=$($backup maintain test 15:15:15 2>&1 || true) && fail_test 7
	[[ $output = "Backup retention policies are invalid." ]] || fail_test 8 "$output"
}

test_invalid_flag_maintenance_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup maintain test "" test 2>&1 || true) && fail_test 1
	[[ $output = "Flag is not supported: test" ]] || fail_test 2 "$output"
}

test_inaccessible_source_dir_maintenance_failure() {
	rm -r "$source_dir"
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup maintain test 2>&1 || true) && fail_test 1
	[[ $output = "Source directory is not accessible." ]] || fail_test 2 "$output"
}

test_nonexistent_destination_maintenance_failure() {
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	output=$($backup maintain test 2>&1 || true) && fail_test 1
	[[ $output = "Destination with the specified ID does not exist." ]] \
		|| fail_test 2 "$output"
}

test_fast_check_maintenance_failure() {
	duplicacy() {
		[[ $1 = check ]] && return 1 || command duplicacy "$@"
	}
	read -r -d "" expected_output <<-EOF
		Repository set to $source_dir
		Storage set to $destination_dir
		Keep 1 snapshot every 15 day(s) if older than 15 day(s)
		No snapshot to delete
	EOF
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	output=$($backup maintain test 15:15 deep 2>&1 || true) && fail_test 1
	[[ "$output" = "$expected_output" ]] || fail_test 2 "$output"
}

test_deep_check_maintenance_failure() {
	duplicacy() {
		[[ $1 = check && $2 = -r ]] && return 1 || command duplicacy "$@"
	}
	read -r -d "" expected_output <<-EOF
		Repository set to $source_dir
		Storage set to $destination_dir
		Keep 1 snapshot every 15 day(s) if older than 15 day(s)
		No snapshot to delete

		Repository set to $source_dir
		Storage set to $destination_dir
		Listing all chunks
		1 snapshots and 0 revisions
		Total chunk size is 0 in 0 chunks
	EOF
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	output=$($backup maintain test 15:15 deep 2>&1 || true) && fail_test 1
	[[ "$output" = "$expected_output" ]] || fail_test 2 "$output"
}

test_cleanup_maintenance_failure() {
	duplicacy() {
		[[ $1 = prune ]] && return 1 || command duplicacy "$@"
	}
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	output=$($backup maintain test 15:15 deep 2>&1 || true) && fail_test 1
	[[ -z $output ]] || fail_test 2 "$output"
}

test_fast_check_maintenance() {
	read -r -d "" expected_output <<-EOF
		Repository set to $source_dir
		Storage set to $destination_dir
		Listing all chunks
		1 snapshots and 0 revisions
		Total chunk size is 0 in 0 chunks
	EOF
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	output=$($backup maintain test) || fail_test 1
	[[ "$output" = "$expected_output" ]] || fail_test 2 "$output"
}

test_deep_check_maintenance() {
	read -r -d "" expected_output <<-EOF
		Repository set to $source_dir
		Storage set to $destination_dir
		Listing all chunks
		1 snapshots and 1 revisions
		Total chunk size is 1K in 4 chunks
		All chunks referenced by snapshot test at revision 1 exist

		Repository set to $source_dir
		Storage set to $destination_dir
		Listing all chunks
		1 snapshots and 1 revisions
		Total chunk size is 1K in 4 chunks
		All files in snapshot test at revision 1 have been successfully verified
	EOF
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	echo test >"$source_dir/test"
	$backup run test >/dev/null
	output=$($backup maintain test "" deep) || fail_test 1
	[[ "$output" = "$expected_output" ]] || fail_test 2 "$output"
}

test_common_maintenance() {
	read -r -d "" expected_output <<-EOF
		Repository set to $source_dir
		Storage set to $destination_dir
		Keep 1 snapshot every 50 day(s) if older than 200 day(s)
		Keep 1 snapshot every 20 day(s) if older than 100 day(s)
		Keep 1 snapshot every 200 day(s) if older than 30 day(s)
		Keep 1 snapshot every 100 day(s) if older than 20 day(s)
		Keep 1 snapshot every 5 day(s) if older than 10 day(s)
		No snapshot to delete

		Repository set to $source_dir
		Storage set to $destination_dir
		Listing all chunks
		1 snapshots and 0 revisions
		Total chunk size is 0 in 0 chunks
	EOF
	new backup lib/backup/DuplicacyBackup "$source_dir" "$metadata_base_dir"
	$backup add_destination test "$destination_dir" test \
		>/dev/null <<<"$destination_pw"$'\n'"$destination_pw"
	cd "$metadata_dir"
	duplicacy set -key password -value "$destination_pw" >/dev/null
	cd "$OLDPWD"
	output=$($backup maintain test 20:100,100:20,200:50,30:200,10:5) || fail_test 1
	[[ "$output" = "$expected_output" ]] || fail_test 2 "$output"
}

run_tests "$0"
