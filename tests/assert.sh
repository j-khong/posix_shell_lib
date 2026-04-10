#!/bin/sh
# Shared assert helpers for posix_shell_lib tests.
# Source this file from every *_test.sh:
#   . "$(cd "$(dirname "$0")" && pwd)/../../assert.sh"   # adjust depth as needed

_pass=0
_fail=0

assert_true() {
    _desc="$1"; shift
    if "$@"; then
        _pass=$((_pass + 1)); printf "  PASS  %s\n" "$_desc"
    else
        _fail=$((_fail + 1)); printf "  FAIL  %s\n" "$_desc"
    fi
}

assert_false() {
    _desc="$1"; shift
    if "$@"; then
        _fail=$((_fail + 1)); printf "  FAIL  %s\n" "$_desc"
    else
        _pass=$((_pass + 1)); printf "  PASS  %s\n" "$_desc"
    fi
}

assert_eq() {
    _desc="$1"; _expected="$2"; _actual="$3"
    if [ "$_actual" = "$_expected" ]; then
        _pass=$((_pass + 1)); printf "  PASS  %s\n" "$_desc"
    else
        _fail=$((_fail + 1)); printf "  FAIL  %s  (expected '%s', got '%s')\n" "$_desc" "$_expected" "$_actual"
    fi
}

assert_empty() {
    _desc="$1"; _actual="$2"
    if [ -z "$_actual" ]; then
        _pass=$((_pass + 1)); printf "  PASS  %s\n" "$_desc"
    else
        _fail=$((_fail + 1)); printf "  FAIL  %s  (expected empty, got '%s')\n" "$_desc" "$_actual"
    fi
}

assert_exit0() {
    _desc="$1"; shift
    if "$@" > /dev/null 2>&1; then
        _pass=$((_pass + 1)); printf "  PASS  %s\n" "$_desc"
    else
        _fail=$((_fail + 1)); printf "  FAIL  %s  (expected exit 0)\n" "$_desc"
    fi
}

assert_exit1() {
    _desc="$1"; shift
    if "$@" > /dev/null 2>&1; then
        _fail=$((_fail + 1)); printf "  FAIL  %s  (expected exit 1)\n" "$_desc"
    else
        _pass=$((_pass + 1)); printf "  PASS  %s\n" "$_desc"
    fi
}

# assert_exitn <desc> <expected_code> <command> [args...]
assert_exitn() {
    _desc="$1"; _expected_code="$2"; shift 2
    "$@" > /dev/null 2>&1; _actual_code=$?
    if [ "$_actual_code" = "$_expected_code" ]; then
        _pass=$((_pass + 1)); printf "  PASS  %s\n" "$_desc"
    else
        _fail=$((_fail + 1)); printf "  FAIL  %s  (expected exit %s, got %s)\n" "$_desc" "$_expected_code" "$_actual_code"
    fi
}

assert_summary() {
    printf "\n%d passed, %d failed\n" "$_pass" "$_fail"
    [ "$_fail" -eq 0 ]
}
