#!/bin/sh
# Tests for src/io/files/json.sh :: extract_json_value

function_name=extract_json_value
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
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Fixture helpers
# ---------------------------------------------------------------------------

_tmpdir="$(mktemp -d)"
_json="$_tmpdir/test.json"

teardown() { rm -rf "$_tmpdir"; }
trap teardown EXIT

cat > "$_json" <<'EOF'
{
    "username": "alice",
    "host": "localhost",
    "port": "8080",
    "path": "some/nested/path",
    "special": "hello & world"
}
EOF

printf "$function_name\n"

# --- success cases
assert_eq    "first key"              "alice"            "$($function_name "$_json" "username")"
assert_eq    "middle key"             "localhost"        "$($function_name "$_json" "host")"
assert_eq    "numeric-string value"   "8080"             "$($function_name "$_json" "port")"
assert_eq    "value with slashes"     "some/nested/path" "$($function_name "$_json" "path")"

# --- exit codes
assert_exitn "existing key exits 0"   0  $function_name "$_json" "username"
assert_exitn "missing key exits 2"    2  $function_name "$_json" "nonexistent"
assert_exitn "missing file exits 1"   1  $function_name "/no/such/file.json" "key"

assert_summary
