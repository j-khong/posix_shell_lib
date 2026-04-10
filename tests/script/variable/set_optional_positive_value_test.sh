#!/bin/sh
# Tests for src/script/variable.sh :: set_optional_positive_value

function_name=set_optional_positive_value
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

# --- valid positive integer: variable must be updated
target="old"
$function_name target "5"
assert_eq "positive integer updates variable" "5" "$target"

target="old"
$function_name target "1"
assert_eq "minimum positive value (1)" "1" "$target"

target="old"
$function_name target "999"
assert_eq "large positive value" "999" "$target"

# --- zero: must NOT update (0 is not > 0)
target="old"
$function_name target "0"
assert_eq "zero does not update variable" "old" "$target"

# --- negative: must NOT update
target="old"
$function_name target "-1"
assert_eq "negative does not update variable" "old" "$target"

# --- empty: must NOT update
target="old"
$function_name target ""
assert_eq "empty does not update variable" "old" "$target"

# --- non-numeric: must NOT update
target="old"
$function_name target "abc"
assert_eq "non-numeric does not update variable" "old" "$target"

# --- float: must NOT update (is_number rejects it)
target="old"
$function_name target "3.14"
assert_eq "float does not update variable" "old" "$target"

assert_summary
