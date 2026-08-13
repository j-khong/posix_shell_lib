#!/bin/sh
# Tests for src/semver.sh :: is_valid
# is_valid returns 0 on success and 1 on failure (no exit), so tests call it
# directly like the other return-based functions (see is_number_test.sh).

function_name=is_valid
folders=""
filename="semver.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/../.."
. "$WORKSPACE_DIR/tests/assert.sh"
. "$WORKSPACE_DIR/tests/config.sh"

sub_path="$(get_lib_root_folder)/$(echo "$folders" | tr ' ' '/')/$filename"
. "$WORKSPACE_DIR/$sub_path"

# `tr -s` squeezes the repeated separator produced when `folders` is empty
# (root-level source file), so the prefix stays single-underscored.
to_concat="$(get_lib_prefix) $folders $(echo "$filename" | sed 's/\.[^.]*$//')"
function_name="$(echo "$to_concat" | tr -s ' ' '_')__$function_name"
# ---------------------------------------------------------------------------

printf "$function_name\n"

# --- valid versions: should return 0
assert_exit0 "basic version"                  $function_name "1.2.3"
assert_exit0 "multi-digit components"         $function_name "10.20.30"
assert_exit0 "zeros"                          $function_name "0.0.0"
assert_exit0 "pre-release"                    $function_name "1.2.3-rc.1"
assert_exit0 "build metadata"                 $function_name "1.2.3+build.5"
assert_exit0 "pre-release and build metadata" $function_name "1.2.3-rc.1+build.5"

# --- invalid versions: should return 1
assert_exit1 "empty string"                   $function_name ""
assert_exit1 "missing patch"                  $function_name "1.2"
assert_exit1 "leading v"                       $function_name "v1.2.3"
assert_exit1 "non-numeric components"         $function_name "a.b.c"
assert_exit1 "trailing dot"                   $function_name "1.2.3."
assert_exit1 "extra numeric component"        $function_name "1.2.3.4"
assert_exit1 "empty pre-release"              $function_name "1.2.3-"

# --- optional print_error logger
my_err() { printf 'custom: %s' "$1"; }
assert_eq    "custom print_error is called on failure" "custom: bad" "$($function_name "bad" my_err)"
assert_exit1 "non-command print_error falls back to default" $function_name "bad" not_a_command

assert_summary
