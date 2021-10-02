public__export_name() {
	command_name=a
}

public__print_help() {
	echo "help A"
}

public__execute() {
	printf "%s\n" "execute A" "$@"
}
