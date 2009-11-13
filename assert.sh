#!/bin/bash
# Copyright (C) 2009 Robert Lehmann

args="$(getopt -l verbose,help,stop,discover vhxd $*)"
for arg in $args; do
    case "$arg" in
        -h|--help)
            echo "usage: $0 [-vxd] [--verbose] [--stop] [--discover]"
            echo "       `sed 's/./ /g' <<< "$0"` [-h | --help]"
            echo "       language-agnostic unit tests for subprocesses"
            exit 0;;
        -v|--verbose)
            DEBUG=1;;
        -x|--stop)
            STOP=1;;
        -d|--discover)
            DISCOVERONLY=1;;
    esac
done

_assert_reset() {
    tests_ran=0 # tests_passed + tests_failed
    tests_passed=0
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
    report_time="$(bc <<< "$tests_endtime - $tests_starttime" \
        | sed -e 's/\.\([0-9]\{0,3\}\)[0-9]*/.\1s/' -e 's/^\./0./')"
    if [[ "$tests_failed" -eq 0 ]]; then
        echo "all $tests passed in $report_time."
    else
        echo "$tests_errors"
        echo "$tests_failed of $tests failed in $report_time."
    fi
    tests_failed_previous=$tests_failed
    _assert_reset
    return $tests_failed_previous
}

assert() {
    # assert <command> <expected stdout> [stdin] [expected status code]
    (( tests_ran++ ))
    [[ -n "$DISCOVERONLY" ]] && return
    expected="$(echo -e "$2")"
    result="$($1 <<< $3)"
    status=$?
    if [[ -n "$4" && "$status" -ne "$4" ]]; then
        failure="program terminated with code $status instead of $4"
    elif [[ "x$result" != "x$expected" ]]; then
        result=$(xargs -I{} echo -n {}\\n <<< "$result" | sed 's/\\n$/\n/')
        [[ -z "$result" ]] && result=nothing
        failure="expected \"$2\"\n\tgot $result"
    else
        [[ -n "$DEBUG" ]] && echo -n .
        (( tests_passed++ ))
        return
    fi
    [[ -n "$DEBUG" ]] && echo -n X
    printf -v report "test #$tests_ran \"$1${3:+ <<< $3}\" failed:\n\t$failure"
    if [[ -n "$STOP" ]]; then
        [[ -n "$DEBUG" ]] && echo
        echo "$report"
        exit 1
    fi
    tests_errors[$tests_failed]="$report"
    (( tests_failed++ ))
}

_assert_reset
