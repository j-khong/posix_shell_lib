#!/bin/sh
# Tests for src/io/filesystem.sh :: check_mandatory_folder

function_name=check_mandatory_folder
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
teardown() { rm -rf "$_tmpdir"; }
trap teardown EXIT

printf "$function_name\n"

# --- folder exists → exit 0
assert_exitn "existing folder exits 0" \
    0  sh -c ". \"$SRC\"; $function_name \"$_tmpdir\""

# --- folder missing → exit 1
assert_exitn "missing folder exits 1" \
    1  sh -c ". \"$SRC\"; $function_name \"$_tmpdir/no_such\""

# --- custom print_error is called, still exits 1
assert_exitn "custom print_error on missing folder exits 1" \
    1  sh -c ". \"$SRC\"
               my_err() { :; }
               $function_name \"$_tmpdir/no_such\" my_err"

# --- non-command print_error falls back to default, still exits 1
assert_exitn "non-command print_error still exits 1" \
    1  sh -c ". \"$SRC\"; $function_name \"$_tmpdir/no_such\" not_a_cmd"

assert_summary
