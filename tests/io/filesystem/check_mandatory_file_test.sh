#!/bin/sh
# Tests for src/io/filesystem.sh :: check_mandatory_file

function_name=check_mandatory_file
folders="io"
filename="filesystem.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/../../.."
. "$WORKSPACE_DIR/tests/assert.sh"
. "$WORKSPACE_DIR/tests/config.sh"

sub_path="$(get_lib_root_folder)/$(echo "$folders" | tr ' ' '/')/$filename"
SRC="$WORKSPACE_DIR/$sub_path"
. "$SRC"

to_concat="$(get_lib_prefix) $folders $(echo "$filename" | sed 's/\.[^.]*$//')"
function_name="$(echo "$to_concat" | tr ' ' '_')__$function_name"
# ---------------------------------------------------------------------------

_tmpdir="$(mktemp -d)"
_existing="$_tmpdir/exists.txt"
teardown() { rm -rf "$_tmpdir"; }
trap teardown EXIT

touch "$_existing"

printf "$function_name\n"

# --- file exists → exit 0
assert_exitn "existing file exits 0" \
    0  sh -c ". \"$SRC\"; $function_name \"$_existing\""

# --- file missing → exit 1
assert_exitn "missing file exits 1" \
    1  sh -c ". \"$SRC\"; $function_name \"$_tmpdir/nope.txt\""

# --- custom print_error is called (exit 1 still occurs)
assert_exitn "custom print_error on missing file exits 1" \
    1  sh -c ". \"$SRC\"
               my_err() { :; }
               $function_name \"$_tmpdir/nope.txt\" my_err"

# --- non-command print_error falls back to default message, still exits 1
assert_exitn "non-command print_error still exits 1" \
    1  sh -c ". \"$SRC\"; $function_name \"$_tmpdir/nope.txt\" not_a_cmd"

assert_summary
