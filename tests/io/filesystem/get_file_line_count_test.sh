#!/bin/sh
# Tests for src/io/filesystem.sh :: get_file_line_count

function_name=get_file_line_count
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

printf "$function_name\n"

# --- empty file
_f="$_tmpdir/empty.txt"; touch "$_f"
assert_eq "empty file → 0" "0" "$($function_name "$_f")"

# --- one line
_f="$_tmpdir/one.txt"; printf "hello\n" > "$_f"
assert_eq "one line" "1" "$($function_name "$_f")"

# --- multiple lines
_f="$_tmpdir/multi.txt"; printf "a\nb\nc\n" > "$_f"
assert_eq "three lines" "3" "$($function_name "$_f")"

# --- missing file → prints 0
assert_eq "missing file prints 0" "0" "$($function_name "/no/such/file")"

# --- empty argument → prints 0
assert_eq "empty arg prints 0" "0" "$($function_name "")"

assert_summary
