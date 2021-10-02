public__export_name() {
	command_name=b
}

public__print_help() {
	echo "help B"
}

public__execute() {
	printf "%s\n" "execute B" "$@"
}
