#!/bin/bash
# Copyright (C) 2009 Robert Lehmann

args="$(getopt -n "$0" -l verbose,help,stop,discover,invariant vhxdi $*)" \
|| exit -1
for arg in $args; do
    case "$arg" in
        -h)
            echo "$0 [-vxid] [--verbose] [--stop] [--invariant] [--discover]"
            echo "`sed 's/./ /g' <<< "$0"` [-h] [--help]"
            exit 0;;
        --help)
            cat <<EOF
Usage: $0 [options]
Language-agnostic unit tests for subprocesses.

Options:
  -v, --verbose    generate output for every individual test
  -x, --stop       stop running tests after the first failure
  -i, --invariant  do not time suites to remain invariant during runs
  -d, --discover   collect test suites only, don't run any tests
  -h               show brief usage information and exit
  --help           show this help message and exit
EOF
            exit 0;;
        -v|--verbose)
            DEBUG=1;;
        -x|--stop)
            STOP=1;;
        -i|--invariant)
            INVARIANT=1;;
        -d|--discover)
            DISCOVERONLY=1;;
    esac
done

printf -v _indent "\n\t" # local format helper

_assert_reset() {
    tests_ran=0
    tests_failed=0
    declare -a tests_errors
    tests_starttime="$(date +%s.%N)" # seconds_since_epoch.nanoseconds
}

assert_end() {
    # assert_end [suite ..]
    tests_endtime="$(date +%s.%N)"
    tests="$tests_ran ${*:+$* }tests"
    [[ -n "$DISCOVERONLY" ]] && echo "collected $tests." && return
    [[ -n "$DEBUG" ]] && echo
    [[ -z "$INVARIANT" ]] && report_time=" in $(bc \
        <<< "$tests_endtime - $tests_starttime" \
        | sed -e 's/\.\([0-9]\{0,3\}\)[0-9]*/.\1/' -e 's/^\./0./')s" \
        || report_time=

    if [[ "$tests_failed" -eq 0 ]]; then
        echo "all $tests passed$report_time."
    else
        for error in "${tests_errors[@]}"; do echo "$error"; done
        echo "$tests_failed of $tests failed$report_time."
    fi
    tests_failed_previous=$tests_failed
    _assert_reset
    return $tests_failed_previous
}

assert() {
    # assert <command> <expected stdout> [stdin]
    (( tests_ran++ ))
    [[ -n "$DISCOVERONLY" ]] && return
    printf -v expected "x$2" # required to overwrite older results
    result="$(eval $1 <<< $3)"
    # Note: $expected is already decorated
    if [[ "x$result" == "$expected" ]]; then
        [[ -n "$DEBUG" ]] && echo -n .
        return
    fi
    result="$(sed -e :a -e '$!N;s/\n/\\n/;ta' <<< "$result")"
    [[ -z "$result" ]] && result="nothing" || result="\"$result\""
    [[ -z "$2" ]] && expected="nothing" || expected="\"$2\""
    failure="expected $expected${_indent}got $result"
    [[ -n "$DEBUG" ]] && echo -n X
    report="test #$tests_ran \"$1${3:+ <<< $3}\" failed:${_indent}$failure"
    tests_errors[$tests_failed]="$report"
    (( tests_failed++ ))
    if [[ -n "$STOP" ]]; then
        [[ -n "$DEBUG" ]] && echo
        echo "$report"
        exit 1
    fi
}

assert_raises() {
    # assert_raises <command> <expected code> [stdin]
    (( tests_ran++ ))
    [[ -n "$DISCOVERONLY" ]] && return
    ($1 <<< $3)
    status=$?
    expected=${2:-0}
    if [[ "$status" -eq "$expected" ]]; then
        [[ -n "$DEBUG" ]] && echo -n .
        return
    fi
    failure="program terminated with code $status instead of $4"
    report="test #$tests_ran \"$1${3:+ <<< $3}\" failed:${_indent}$failure"
    tests_errors[$tests_failed]="$report"
    (( tests_failed++ ))
    if [[ -n "$STOP" ]]; then
        [[ -n "$DEBUG" ]] && echo
        echo "$report"
        exit 1
    fi
}

_assert_reset
