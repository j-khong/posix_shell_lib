#!/bin/sh
# Tests for src/io/files/json.sh :: set_json_value

function_name=set_json_value
folders="io files"
filename="json.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/../../../.."
. "$WORKSPACE_DIR/tests/assert.sh"
. "$WORKSPACE_DIR/tests/config.sh"

sub_path="$(get_lib_root_folder)/$(echo "$folders" | tr ' ' '/')/$filename"
. "$WORKSPACE_DIR/$sub_path"

to_concat="$(get_lib_prefix) $folders $(echo "$filename" | sed 's/\.[^.]*$//')"
function_name="$(echo "$to_concat" | tr ' ' '_')__$function_name"

helper_function="$(echo "$to_concat" | tr ' ' '_')__extract_json_value"
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Fixture helpers
# ---------------------------------------------------------------------------

_tmpdir="$(mktemp -d)"

teardown() { rm -rf "$_tmpdir"; }
trap teardown EXIT

make_json() {
    _f="$_tmpdir/$1.json"
    cat > "$_f" <<'EOF'
{
    "username": "alice",
    "host": "localhost",
    "port": "8080"
}
EOF
    printf "%s" "$_f"
}

printf "$function_name\n"

# --- value is updated
_f="$(make_json update)"
$function_name "$_f" "username" "bob"
assert_eq "value updated" "bob" "$($helper_function "$_f" "username")"

# --- other keys unchanged
assert_eq "other key untouched" "localhost" "$($helper_function "$_f" "host")"
assert_eq "other key untouched" "8080"      "$($helper_function "$_f" "port")"

# --- update to empty string
_f="$(make_json empty)"
$function_name "$_f" "host" ""
assert_eq "value set to empty string" "" "$($helper_function "$_f" "host")"

# --- value containing slashes
_f="$(make_json slash)"
$function_name "$_f" "host" "some/path/value"
assert_eq "value with slashes" "some/path/value" "$($helper_function "$_f" "host")"

# --- backup file is cleaned up on success
_f="$(make_json backup)"
$function_name "$_f" "port" "9090"
assert_false "backup file removed after success" test -f "${_f}.bak"

# --- exit code 0 on success
_f="$(make_json exit0)"
assert_exitn "exits 0 on success" 0 $function_name "$_f" "username" "carol"

assert_summary
