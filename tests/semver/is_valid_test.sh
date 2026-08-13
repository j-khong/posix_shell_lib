#!/bin/sh
# Tests for src/semver.sh :: is_valid
# The function calls exit(1) on failure, so each negative test runs
# in a dedicated subshell to avoid killing the test process.

function_name=is_valid
folders=""
filename="semver.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/../.."
. "$WORKSPACE_DIR/tests/assert.sh"
. "$WORKSPACE_DIR/tests/config.sh"

sub_path="$(get_lib_root_folder)/$(echo "$folders" | tr ' ' '/')/$filename"
SRC="$WORKSPACE_DIR/$sub_path"
. "$SRC"

# `tr -s` squeezes the repeated separator produced when `folders` is empty
# (root-level source file), so the prefix stays single-underscored.
to_concat="$(get_lib_prefix) $folders $(echo "$filename" | sed 's/\.[^.]*$//')"
function_name="$(echo "$to_concat" | tr -s ' ' '_')__$function_name"
# ---------------------------------------------------------------------------

printf "$function_name\n"

# --- valid versions: should succeed (exit 0)
assert_exit0 "basic version" \
    sh -c ". \"$SRC\"; $function_name \"1.2.3\""

assert_exit0 "multi-digit components" \
    sh -c ". \"$SRC\"; $function_name \"10.20.30\""

assert_exit0 "zeros" \
    sh -c ". \"$SRC\"; $function_name \"0.0.0\""

assert_exit0 "pre-release" \
    sh -c ". \"$SRC\"; $function_name \"1.2.3-rc.1\""

assert_exit0 "build metadata" \
    sh -c ". \"$SRC\"; $function_name \"1.2.3+build.5\""

assert_exit0 "pre-release and build metadata" \
    sh -c ". \"$SRC\"; $function_name \"1.2.3-rc.1+build.5\""

# --- invalid versions: should exit 1
assert_exit1 "empty string" \
    sh -c ". \"$SRC\"; $function_name \"\""

assert_exit1 "missing patch" \
    sh -c ". \"$SRC\"; $function_name \"1.2\""

assert_exit1 "leading v" \
    sh -c ". \"$SRC\"; $function_name \"v1.2.3\""

assert_exit1 "non-numeric components" \
    sh -c ". \"$SRC\"; $function_name \"a.b.c\""

assert_exit1 "trailing dot" \
    sh -c ". \"$SRC\"; $function_name \"1.2.3.\""

assert_exit1 "extra numeric component" \
    sh -c ". \"$SRC\"; $function_name \"1.2.3.4\""

assert_exit1 "empty pre-release" \
    sh -c ". \"$SRC\"; $function_name \"1.2.3-\""

# --- custom print_error function is called on failure (still exit 1)
assert_exit1 "custom print_error called on failure" \
    sh -c ". \"$SRC\"
           my_err() { printf 'custom: %s\n' \"\$1\"; }
           $function_name \"bad\" my_err"

# --- custom print_error NOT a command: default message, still exit 1
assert_exit1 "non-command print_error falls back to default" \
    sh -c ". \"$SRC\"; $function_name \"bad\" not_a_command"

assert_summary
