#!/usr/bin/env bash

source assert.sh
source assert-extras.sh

assert "echo foo" "foo"
assert_raises "true" 0
assert_raises "exit 127" 127

assert_end sanity

###
### assert_success tests
###

# Tests expecting success
assert_success "true"
assert_success "echo foo"
assert_success "cat" "foo"

# Tests expecting failure
assert_raises 'assert_success "false"' 1
assert_raises 'assert_success "exit 1"' 1

assert_end assert_success

###
### assert_failure tests
###

# Tests expecting success
assert_failure "false"
assert_failure "exit 1"
assert_failure "exit -1"
assert_failure "exit 42"
assert_failure "exit -42"

# Tests expecting failure
assert_raises 'assert_failure "true"' 1
assert_raises 'assert_failure "echo foo"' 1

assert_end assert_failure

###
### assert_contains tests
###

# Tests expecting success
assert_contains "echo foo" "foo"
assert_contains "echo foobar" "foo"
assert_contains "echo foo bar" "foo"
assert_contains "echo foo bar" "bar"
assert_contains "echo foo bar" "foo bar"

# Tests expecting failure
assert_failure 'assert_contains "echo foo" "foot"'
assert_failure 'assert_contains "echo foo" "f.."'

# Multi-word argument tests
assert_contains "echo foo bar" "foo bar"
assert_failure 'assert_contains "echo foo; echo bar" "foo bar"'

# Multi-argument tests
assert_contains "echo foo bar baz" "foo" "baz"
assert_failure 'assert_contains "echo foo bar baz" "bar" "foo baz"'

assert_end assert_contains

###
### assert_matches tests
###

# Tests expecting success
assert_matches "echo foo" "f.."
assert_matches "echo foobar" "f."
assert_matches "echo foo bar" "^foo bar$"
assert_matches "echo foo bar" "[az ]+"

# Tests expecting failure
assert_failure 'assert_matches "echo foot" "foo$"'

# Multi-word argument tests
assert_matches "echo foo bar" "foo .*"
assert_failure 'assert_matches "echo foo; echo bar" "foo .*"'

# Multi-argument tests
assert_matches "echo foo bar baz" "^f.." "baz$"
assert_failure 'assert_matches "echo foo bar baz" "bar" "foo baz"'

assert_end assert_matches

###
### assert_startswith tests
###

# Tests expecting success
assert_startswith "echo foo" "f"
assert_startswith "echo foo" "foo"
assert_startswith "echo foo; echo bar" "foo"

# Tests expecting failure
assert_failure 'assert_startswith "echo foo" "oo"'
assert_failure 'assert_startswith "echo foo; echo bar" "foo bar"'
assert_failure 'assert_startswith "echo foo" "."'

assert_end assert_startswith

###
### assert_endswith tests
###

# Tests expecting success
assert_endswith "echo foo" "oo"
assert_endswith "echo foo" "foo"
assert_endswith "echo foo; echo bar" "bar"

# Tests expecting failure
assert_failure 'assert_endswith "echo foo" "f"'
assert_failure 'assert_endswith "echo foo; echo bar" "foo bar"'
assert_failure 'assert_endswith "echo foo" "."'

assert_end assert_endswith