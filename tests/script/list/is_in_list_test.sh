#!/bin/sh
# Tests for src/script/list.sh :: is_in_list

function_name=is_in_list
folders="script"
filename="list.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/../../.."
. "$WORKSPACE_DIR/tests/assert.sh"
. "$WORKSPACE_DIR/tests/config.sh"

sub_path="$(get_lib_root_folder)/$(echo "$folders" | tr ' ' '/')/$filename"
. "$WORKSPACE_DIR/$sub_path"

to_concat="$(get_lib_prefix) $folders $(echo "$filename" | sed 's/\.[^.]*$//')"
function_name="$(echo "$to_concat" | tr ' ' '_')__$function_name"
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Test cases
# ---------------------------------------------------------------------------

printf "$function_name\n"

# --- positive cases
assert_true  "first value in list"              $function_name "val1 val2 val3" "val1"
assert_true  "middle value in list"             $function_name "val1 val2 val3" "val2"
assert_true  "last value in list"               $function_name "val1 val2 val3" "val3"
assert_true  "single-element list — match"      $function_name "val1" "val1"

# --- negative cases
assert_false "value absent from list"           $function_name "val1 val2 val3" "val4"
assert_false "empty list"                       $function_name "" "val1"
assert_false "single-element list — no match"   $function_name "val1" "val2"
assert_false "partial substring must not match" $function_name "val1 val2 val3" "val"
assert_false "prefix substring must not match"  $function_name "val1 val2 val3" "val1 val2"
assert_false "empty value not in list"          $function_name "val1 val2" ""

# ---------------------------------------------------------------------------
# Bash-array behaviour (documents the known limitation)
# ---------------------------------------------------------------------------
# list=(val1 val2 val3) creates an indexed array in bash.
# $list expands to the first element only → is_in_list receives "val1", not the full list.
# ${list[*]} expands to all elements → is_in_list works as expected.

if command -v bash > /dev/null 2>&1; then
    printf "\nis_in_list — bash array behaviour\n"

    _src="$WORKSPACE_DIR/$sub_path"

    # $list only gives the first element: val2 and val3 are NOT found
    assert_false 'bash: list=(val1 val2 val3); $list → only val1 — val2 NOT found' \
        bash -c ". \"$_src\"; list=(val1 val2 val3); $function_name \"\$list\" val2"

    assert_false 'bash: list=(val1 val2 val3); $list → only val1 — val3 NOT found' \
        bash -c ". \"$_src\"; list=(val1 val2 val3); $function_name \"\$list\" val3"

    assert_true  'bash: list=(val1 val2 val3); $list → only val1 — val1 found' \
        bash -c ". \"$_src\"; list=(val1 val2 val3); $function_name \"\$list\" val1"

    # ${list[*]} expands to the full space-separated string → works correctly
    assert_true  'bash: list=(val1 val2 val3); ${list[*]} — val2 found' \
        bash -c ". \"$_src\"; list=(val1 val2 val3); $function_name \"\${list[*]}\" val2"

    assert_true  'bash: list=(val1 val2 val3); ${list[*]} — val3 found' \
        bash -c ". \"$_src\"; list=(val1 val2 val3); $function_name \"\${list[*]}\" val3"
else
    printf "\n(bash not available — skipping array behaviour tests)\n"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

assert_summary
