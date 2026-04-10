#!/bin/sh
# Run all *_test.sh files found under tests/
# Usage: sh tests/run_tests.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

_total=0
_fail=0

for test_file in $(find "$SCRIPT_DIR" -name '*_test.sh' | sort); do
    label="${test_file#$SCRIPT_DIR/}"
    _total=$((_total + 1))
    printf "%-60s " "$label"
    if output=$(sh "$test_file" 2>&1); then
        printf "✅ PASS\n"
    else
        _fail=$((_fail + 1))
        printf "❌ FAIL\n"
        printf "%s\n" "$output" | sed 's/^/    /'
    fi
done

printf "\n%d/%d test files passed\n" "$((_total - _fail))" "$_total"
[ "$_fail" -eq 0 ]
