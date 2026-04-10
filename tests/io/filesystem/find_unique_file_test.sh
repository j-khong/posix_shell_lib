#!/bin/sh
# Tests for src/io/filesystem.sh :: find_unique_file

function_name=find_unique_file
folders="io"
filename="filesystem.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/../../.."
. "$WORKSPACE_DIR/tests/assert.sh"
. "$WORKSPACE_DIR/tests/config.sh"

sub_path="$(get_lib_root_folder)/$(echo "$folders" | tr ' ' '/')/$filename"
. "$WORKSPACE_DIR/$sub_path"

to_concat="$(get_lib_prefix) $folders $(echo "$filename" | sed 's/\.[^.]*$//')"
function_name="$(echo "$to_concat" | tr ' ' '_')__$function_name"
# ---------------------------------------------------------------------------

_tmpdir="$(mktemp -d)"
teardown() { rm -rf "$_tmpdir"; }
trap teardown EXIT

# fixture: one txt, two log files
touch "$_tmpdir/report.txt"
touch "$_tmpdir/app.log"
touch "$_tmpdir/db.log"

printf "$function_name\n"

# --- success: exactly one match
assert_eq    "unique match returns filename" \
    "$(basename "$_tmpdir/report.txt")" \
    "$(basename "$($function_name "$_tmpdir" '\.txt$')")"
assert_exitn "unique match exits 0"  0  $function_name "$_tmpdir" '\.txt$'

# --- missing directory → exit 1
assert_exitn "missing dir exits 1"   1  $function_name "/no/such/dir" '.*'

# --- no match → exit 2
assert_exitn "no match exits 2"      2  $function_name "$_tmpdir" '\.csv$'

# --- multiple matches → exit 3
assert_exitn "multiple matches exits 3" 3 $function_name "$_tmpdir" '\.log$'

assert_summary
