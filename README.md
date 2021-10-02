# toolbelt.sh

An object-oriented command-line utility framework for the Unix shell.

## Table of Contents

- [Why?](#why)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
    - [Single-Command Utilities](#single-command-utilities)
    - [Multi-Command Utilities](#multi-command-utilities)

## Why?

Object-oriented software development frameworks have become the foundation of many projects. As a result, a lot of professionals are very familiar with the structure of such frameworks. toolbelt.sh brings this familiar structure to the Unix shell to turn the creation of command-line utilities into a more pleasant experience.

## Features

- An evergrowing list of helpful objects that can be composed into full command-line utilities.
- A simple structure that eases the creation of complex command-line utilities.

## Requirements

- bash
- [soop.sh][1]
- Some objects have additional dependencies which are outlined in the class file after the file header.

## Installation

Installing toolbelt.sh is as simple as storing the contents of the `lib` directory in a location of choice.

## Usage

> **Note:** Check the [soop.sh][1] documentation to get an understanding of how to work with toolbelt.sh objects.

<!-- -->
> **Note:** Every class file contains documentation (unless the functionality is deemed self-explanatory) that should answer many usage questions.

### Single-Command Utilities

If you are working on a command-line utility that is not composed of multiple commands, you can simply use toolbelt.sh objects (and custom-made objects) inside a shell script. For example:

```sh
#!/bin/bash

. /path/to/soop.sh

print_help() {
	cat <<-EOF
		Maintain a backup.

		Usage:
		  ${0##*/} [-d] <source> <destination>
		  ${0##*/} -h

		Operands:
		  <source>       Absolute path to the source directory.
		  <destination>  ID of the destination that should be maintained.

		Options:
		  -d  Execute deep maintenance.
		  -h  Print help.
	EOF
}

new args /path/to/toolbelt.sh/lib/utility/BasicArgs dh "$@"
$args parse

[[ -n $arg_opt_h ]] && print_help && exit

new backup /path/to/toolbelt.sh/lib/backup/DuplicacyBackup "${arg_pos[0]}"
maintain_cmd_args=("${arg_pos[1]}" 7:1,30:7,365:30,1095:0)
[[ -n $arg_opt_d ]] && maintain_cmd_args+=(deep)
$backup maintain "${maintain_cmd_args[@]}"
```

### Multi-Command Utilities

If you are working on a command-line utility that is composed of multiple commands, you can use command objects to increase maintainability. For example:

```sh
# /usr/local/lib/backup/RunBackupCommand.sh

ro__command_name=backup/run

public__export_name() {
	$self command_name:
}

public__print_help() {
	local command_name && $self "$_:"
	cat <<-EOF
		Run a backup.

		Usage:
		  ${0##*/} $command_name <source> <destination>

		Operands:
		  <source>       Absolute path to the source directory.
		  <destination>  ID of the destination where the backup should be
		                 stored.
	EOF
}

public__execute() {
	local backup
	new backup /path/to/toolbelt.sh/lib/backup/DuplicacyBackup "$1"
	$backup run "$2"
}
```

```sh
# /usr/local/lib/backup/RestoreBackupCommand.sh

ro__command_name=backup/restore

public__export_name() {
	$self command_name:
}

public__print_help() {
	local command_name && $self "$_:"
	cat <<-EOF
		Restore a backup.

		Usage:
		  ${0##*/} $command_name <source> <destination> <snapshot>

		Operands:
		  <source>       Absolute path to the source directory.
		  <destination>  ID of the destination from which the backup should be
		                 restored.
		  <snapshot>     ID of the snapshot that should be restored.
	EOF
}

public__execute() {
	local backup
	new backup /path/to/toolbelt.sh/lib/backup/DuplicacyBackup "$1"
	$backup restore "$2" "$3"
}
```

```sh
#!/bin/bash

. /path/to/soop.sh

new run_backup_command /usr/local/lib/backup/RunBackupCommand
new restore_backup_command /usr/local/lib/backup/RestoreBackupCommand
new utility /path/to/toolbelt.sh/lib/utility/CommandUtility \
	"$run_backup_command" "$restore_backup_command"

$utility run "$@"
```

> **Note:** The interface for command objects is outlined inside `lib/utility/Command.sh`.

[1]: https://github.com/TobyGiacometti/soop.sh
