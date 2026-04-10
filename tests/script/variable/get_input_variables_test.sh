#!/bin/sh
# Tests for src/script/variable.sh :: get_input_variables

function_name=get_input_variables
folders="script"
filename="variable.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/../../.."
. "$WORKSPACE_DIR/tests/assert.sh"
. "$WORKSPACE_DIR/tests/config.sh"

sub_path="$(get_lib_root_folder)/$(echo "$folders" | tr ' ' '/')/$filename"
. "$WORKSPACE_DIR/$sub_path"

to_concat="$(get_lib_prefix) $folders $(echo "$filename" | sed 's/\.[^.]*$//')"
function_name="$(echo "$to_concat" | tr ' ' '_')__$function_name"
# ---------------------------------------------------------------------------

printf "$function_name\n"

# --- all values provided
$function_name "a b c" "foo" "bar" "baz"
assert_eq "first variable set"   "foo" "$a"
assert_eq "second variable set"  "bar" "$b"
assert_eq "third variable set"   "baz" "$c"

# --- single variable
$function_name "x" "hello"
assert_eq "single variable set" "hello" "$x"

# --- fewer args than variable names → remaining vars set to empty
$function_name "p q" "only_one"
assert_eq    "provided arg assigned" "only_one" "$p"
assert_empty "missing arg is empty"  "$q"

# --- value with spaces (passed as single quoted arg)
$function_name "msg" "hello world"
assert_eq "value with spaces" "hello world" "$msg"

assert_summary
