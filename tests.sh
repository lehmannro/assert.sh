#!/bin/bash

. assert.sh

assert "echo"                       # no output expected
assert "echo foo" "foo"             # output expected
assert "cat" "bar" "bar"            # output expected if input's given
assert_raises "true" 0 ""           # status code expected
assert_raises "exit 127" 127 ""     # status code expected
assert "head -1 < $0" "#!/bin/bash" # redirections
assert "seq 2" "1\n2"               # multi-line output expected
assert_end demo

_clean() {
    _assert_reset
    DEBUG= STOP= INVARIANT=1 DISCOVERONLY=
    eval $*
}

assert "_clean; assert true; assert_end" \
"all 1 tests passed."
assert "_clean; assert 'seq 1'; assert_end" \
'test #1 "seq 1" failed:\n\texpected nothing\n\tgot "1"\n1 of 1 tests failed.'
assert "_clean; assert true '1'; assert_end" \
'test #1 "true" failed:\n\texpected "1"\n\tgot nothing\n1 of 1 tests failed.'
assert "_clean DEBUG=1; assert true; assert_end" \
".\nall 1 tests passed."
assert "_clean DEBUG=1; assert_raises false; assert_end" \
'X\ntest #1 "false" failed:\n\tprogram terminated with code 1 instead of 0
1 of 1 tests failed.'
assert "_clean DISCOVERONLY=1; assert true; assert false; assert_end" \
"collected 2 tests."
assert "_clean STOP=1 assert_raises false; assert_end" \
'test #1 "false" failed:\n\tprogram terminated with code 1 instead of 0'
assert_raises "_clean INVARIANT=;
assert_end | egrep 'all 0 tests passed in [0-9].[0-9]{3}s'"
assert_raises "_clean; assert_raises false; assert_raises false; assert_end" 2
assert_end output
