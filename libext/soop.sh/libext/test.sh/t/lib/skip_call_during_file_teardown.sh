_testsh_fork

. ./test.sh

teardown_test_file() {
	skip_test
	printf "%s\n" teardown_test_file
}
