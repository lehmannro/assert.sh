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

assert_reset() {
    tests_passed=0
    tests_failed=0
    tests_ran=0
    declare -a test_errors
    test_starttime="$(date +%s.%N)"
}

assert_end() {
    # assert_end [suite]
    test_endtime="$(date +%s.%N)"
    tests="$tests_ran ${1:+$1 }tests"
    [ -n "$DISCOVERONLY" ] && echo "collected $tests." && return
    [ -n "$DEBUG" ] && echo
    report_time="in `echo "$test_endtime - $test_starttime" \
        | bc \
        | sed -e 's/\.\([0-9]\{0,3\}\)[0-9]*/.\1/' -e 's/^\./0./'`s"
    if [ "$tests_failed" -eq 0 ]; then
        echo "all $tests passed $report_time."
    else
        echo "$test_errors"
        echo "$tests_failed of $tests failed $report_time."
    fi
    assert_reset
}

assert() {
    # assert <command> <expected stdout> [stdin] [expected status code]
    (( tests_ran++ ))
    [ -n "$DISCOVERONLY" ] && return
    expected="$(echo -e "$2")"
    result="$($1 <<< $3)"
    status=$?
    notice="test #$tests_ran \"$1${3:+ <<< $3}\" failed:"
    if [ -n "$4" ] && [ "$status" -ne "$4" ]; then
        test_errors[$tests_failed]=$(echo -e "$notice\
            \n\tprogram terminated with code $status instead of $4")
    elif [ "x$result" != "x$expected" ]; then
        result=$(xargs -I{} echo -n {}\\n <<< "$result" | sed 's/\\n$/\n/')
        [ -z "$result" ] && result=nothing
        test_errors[$tests_failed]=$(echo -e "$notice\
            \n\texpected \"$2\"\n\tgot $result")
    else
        [ -n "$DEBUG" ] && echo -n .
        (( tests_passed++ ))
        return
    fi
    [ -n "$DEBUG" ] && echo -n X
    (( tests_failed++ ))
    if [ -n "$STOP" ]; then
        [ -n "$DEBUG" ] && echo
        echo "$test_errors"
        exit 1
    fi
}

assert_reset
