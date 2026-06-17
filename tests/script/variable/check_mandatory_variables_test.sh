#!/bin/sh
# Tests for src/script/variable.sh :: check_mandatory_variables
# The function calls exit(1) on failure, so each negative test runs
# in a dedicated subshell to avoid killing the test process.

function_name=check_mandatory_variables
folders="script"
filename="variable.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/../../.."
. "$WORKSPACE_DIR/tests/assert.sh"
. "$WORKSPACE_DIR/tests/config.sh"

sub_path="$(get_lib_root_folder)/$(echo "$folders" | tr ' ' '/')/$filename"
SRC="$WORKSPACE_DIR/$sub_path"
. "$SRC"

to_concat="$(get_lib_prefix) $folders $(echo "$filename" | sed 's/\.[^.]*$//')"
function_name="$(echo "$to_concat" | tr ' ' '_')__$function_name"
# ---------------------------------------------------------------------------

printf "$function_name\n"

# --- all variables set: should succeed (exit 0)
assert_exit0 "all variables set" \
    sh -c ". \"$SRC\"; VAR1=hello VAR2=world; $function_name \"VAR1 VAR2\""

assert_exit0 "single variable set" \
    sh -c ". \"$SRC\"; MYVAR=value; $function_name \"MYVAR\""

# --- one variable missing: should exit 1
assert_exit1 "first variable empty" \
    sh -c ". \"$SRC\"; VAR1=''; VAR2=world; $function_name \"VAR1 VAR2\""

assert_exit1 "second variable empty" \
    sh -c ". \"$SRC\"; VAR1=hello; VAR2=''; $function_name \"VAR1 VAR2\""

assert_exit1 "variable not set at all" \
    sh -c ". \"$SRC\"; unset MYVAR 2>/dev/null; MYVAR=''; $function_name \"MYVAR\""

# --- custom print_error function is called (we verify exit 1 still occurs)
assert_exit1 "custom print_error called on failure" \
    sh -c ". \"$SRC\"
           my_err() { printf 'custom: %s\n' \"$1\" >/dev/null; }
           MISSING=''
           $function_name \"MISSING\" my_err"

# --- custom print_error NOT a command: default message, still exit 1
assert_exit1 "non-command print_error falls back to default" \
    sh -c ". \"$SRC\"; BAD=''; $function_name \"BAD\" not_a_command"

# --- IFS=, with space-separated variable list
assert_exit0 "IFS=, with space-separated var list (all set)" \
    sh -c "IFS=,; . \"$SRC\"; VAR1=hello VAR2=world; $function_name \"VAR1 VAR2\""

assert_exit1 "IFS=, with space-separated var list (one missing)" \
    sh -c "IFS=,; . \"$SRC\"; VAR1=hello VAR2=; $function_name \"VAR1 VAR2\""

assert_summary
