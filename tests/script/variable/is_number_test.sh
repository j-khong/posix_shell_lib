#!/bin/sh
# Tests for src/script/variable.sh :: is_number

function_name=is_number
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

# --- positive cases
assert_true  "zero"                    $function_name "0"
assert_true  "single digit"            $function_name "5"
assert_true  "multi-digit"             $function_name "42"
assert_true  "large number"            $function_name "1000000"

# --- negative cases
assert_false "empty string"            $function_name ""
assert_false "negative number"         $function_name "-1"
assert_false "float"                   $function_name "3.14"
assert_false "string"                  $function_name "abc"
assert_false "alphanumeric"            $function_name "12abc"
assert_false "leading space"           $function_name " 1"
assert_false "trailing space"          $function_name "1 "
assert_false "plus sign"               $function_name "+1"

assert_summary
