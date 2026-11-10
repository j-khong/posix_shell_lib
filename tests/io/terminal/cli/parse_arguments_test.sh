#!/bin/sh
# Tests for src/io/terminal/cli.sh :: parse_arguments

function_name=parse_arguments
folders="io terminal"
filename="cli.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/../../../.."
. "$WORKSPACE_DIR/tests/assert.sh"
. "$WORKSPACE_DIR/tests/config.sh"

sub_path="$(get_lib_root_folder)/$(echo "$folders" | tr ' ' '/')/$filename"
SRC="$WORKSPACE_DIR/$sub_path"
. "$SRC"

to_concat="$(get_lib_prefix) $folders $(echo "$filename" | sed 's/\.[^.]*$//')"
function_name="$(echo "$to_concat" | tr ' ' '_')__$function_name"
# ---------------------------------------------------------------------------

_tmpdir="$(mktemp -d)"
teardown() { rm -rf "$_tmpdir"; }
trap teardown EXIT

_conf="$_tmpdir/test.cli.conf"
cat > "$_conf" <<CONF
# type | short | long | variable | default | description
opt  | p | project | project | def | the project
flag | v | verbose | verbose | 0   | verbose output
pos  |   |         | target  |     | the target
CONF

# run <args...> : parse in a subshell and print the resulting variables
run() {
    sh -c ". \"$SRC\"
           $function_name \"$_conf\" prog \"\$@\" || exit 1
           echo \"project=\$project verbose=\$verbose target=\$target\"" sh "$@" 2>&1
}

printf "$function_name\n"

# --- values and defaults
assert_eq "defaults + positional" \
    "project=def verbose=0 target=t"  "$(run t)"
assert_eq "short option with value" \
    "project=x verbose=0 target=t"    "$(run -p x t)"
assert_eq "long option with value" \
    "project=x verbose=0 target=t"    "$(run --project x t)"
assert_eq "long option with =" \
    "project=x verbose=0 target=t"    "$(run --project=x t)"
assert_eq "flag" \
    "project=def verbose=1 target=t"  "$(run -v t)"
assert_eq "options after the positional argument" \
    "project=x verbose=1 target=t"    "$(run t -v --project x)"
assert_eq "value with spaces" \
    "project=a b verbose=0 target=t"  "$(run --project "a b" t)"
assert_eq "-- ends the options" \
    "project=def verbose=0 target=-v" "$(run -- -v)"

# --- errors
assert_exitn "unknown option exits 1" \
    1  run --nope t
assert_exitn "option without value exits 1" \
    1  run t -p
assert_exitn "missing positional exits 1" \
    1  run
assert_exitn "too many positionals exits 1" \
    1  run a b
assert_exitn "missing conf file exits 1" \
    1  sh -c ". \"$SRC\"; $function_name \"$_tmpdir/nope.conf\" prog t"

# --- help
assert_exitn "--help exits 0" \
    0  run --help
case "$(run -h)" in
    "usage: prog [-p <value>] [-v] <target>"*) assert_true "help prints the usage" true ;;
    *) assert_true "help prints the usage" false ;;
esac

assert_summary
