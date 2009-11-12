#!/bin/bash

. assert.sh

assert "echo"                 # no output expected
assert "echo foo" "foo"       # output expected
assert "cat" "bar" "bar"      # output expected if input's given
assert "true" "" "" 0         # status code expected
assert "exit 127" "" "" 127   # status code expected
assert "echo > spam" "> spam" # no redirections
assert "seq 2" "1\n2"         # multi-line output expected
assert_end
