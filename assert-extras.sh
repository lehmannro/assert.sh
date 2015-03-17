#!/usr/bin/env bash

# assert-extras.sh 1.1 - supplementary bash unit testing functions
# Note: This script should be sourced together with assert.sh,
#       it is dependent on the functionality provided by that script.

# assert_success <command> [stdin]
assert_success() {
	assert_raises "$1" 0 "${2:-}"
}

# assert_failure <command> [stdin]
assert_failure() {
    (( tests_ran++ )) || :
    [[ -z "$DISCOVERONLY" ]] || return
    status=0
    (eval "$1" <<< ${2:-}) > /dev/null 2>&1 || status=$?
    if [[ "$status" != "0" ]]; then
        [[ -z "$DEBUG" ]] || echo -n .
        return
    fi
    _assert_fail "program terminated with a zero return code; expecting non-zero return code" \
    	"$1" "$2"
}

# assert_contains <command> <expected output...>
assert_contains() {
	_assert_with_grep '-F' "$@"
}

# assert_matches <command> <expected output...>
assert_matches() {
	_assert_with_grep '-E' "$@"
}

# assert_startswith <command> <expected start to stdout>
assert_startswith() {
	assert_success "[[ '$($1)' == '$2'* ]]"
}

# assert_endswith <command> <expected start to stdout>
assert_endswith() {
	assert_success "[[ '$($1)' == *'$2' ]]"
}

# _assert_with_grep <grep modifiers> <command> <expected output...>
_assert_with_grep() {
    local grep_modifier="$1"
    local output="$($2)"
    shift 2

    while [ $# != 0 ]; do
    	assert_raises "echo '$output' | $GREP $grep_modifier '$1'" 0 || return 1
    	shift
    done
}

# Returns the resolved command, preferring any gnu-versions of the cmd (prefixed with 'g') on
# non-Linux systems such as Mac OS, and falling back to the standard version if not.
_cmd() {
	local cmd="$1"

	local gnu_cmd="g$cmd"
	local gnu_cmd_found=$(which "$gnu_cmd" 2> /dev/null)
	if [ "$gnu_cmd_found" ]; then
		echo "$gnu_cmd_found"
	else
		if [ "$(uname)" == 'Darwin' ]; then
			echo "Warning: Cannot find gnu version of command '$cmd' ($gnu_cmd) on path." \
			     "Falling back to standard command" >&2
		fi
		echo "cmd"
	fi
}

GREP=$(_cmd grep)
