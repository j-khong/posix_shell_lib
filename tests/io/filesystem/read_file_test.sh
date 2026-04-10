#!/bin/sh
# Tests for src/io/filesystem.sh :: read_file

function_name=read_file
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

# --- callback receives correct total, index and line content
_f="$_tmpdir/data.txt"
printf "alpha\nbeta\ngamma\n" > "$_f"

_got_total=""
_got_lines=""
_got_indices=""
collect() {
    _total="$1"; _idx="$2"; _line="$3"
    _got_total="$_total"
    _got_lines="$_got_lines|$_line"
    _got_indices="$_got_indices|$_idx"
}

$function_name "$_f" collect

assert_eq "total passed to callback"  "3"              "$_got_total"
assert_eq "lines collected"           "|alpha|beta|gamma" "$_got_lines"
assert_eq "indices start at 0"        "|0|1|2"         "$_got_indices"

# --- empty file: callback never called
_f="$_tmpdir/empty.txt"; touch "$_f"
_called=0
noop_cb() { _called=$((_called + 1)); }
$function_name "$_f" noop_cb
assert_eq "empty file: callback not called" "0" "$_called"

# --- missing file: no error, callback not called
_called=0
$function_name "$_tmpdir/no_such.txt" noop_cb
assert_eq "missing file: callback not called" "0" "$_called"

assert_summary
