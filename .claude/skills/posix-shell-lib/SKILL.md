---
name: posix-shell-lib
description: Reference library for writing shell scripts. Use whenever you write, modify or review a sh/bash script (file handling, JSON read/write, terminal colors/menus/confirmations, argument and variable checks, list membership, semver). Check the function index first and reuse posix_shell_lib instead of re-implementing helpers; scripts must stay POSIX sh.
---

# posix_shell_lib

Library of reusable POSIX shell functions (https://github.com/j-khong/posix_shell_lib).
It is the reference for shell scripting: before writing a helper in a script, look for it in the index.

- Function index (name, description, file): [FUNCTIONS.md](FUNCTIONS.md)
- Full documentation of a function (arguments, return codes, examples): comment block above it in `src/<file>` of the lib repo, or in `~/.posix_shell_lib/latest/<file>` once installed.

## Install

```sh
# latest version in $HOME (installs into $HOME/.posix_shell_lib/<version>, symlink "latest")
curl -sL https://raw.githubusercontent.com/j-khong/posix_shell_lib/refs/heads/main/release/install.sh | sh
```

If `~/.posix_shell_lib/latest` already exists, it is installed. Do not reinstall.
The installer links this skill into `~/.claude/skills` when run with `INSTALL_SKILL=1`.

## Use in a script

```sh
#!/bin/sh
# import everything
. "$HOME/.posix_shell_lib/latest/import.sh"
# or a single file
# . "$HOME/.posix_shell_lib/latest/io/filesystem.sh"

input_var_list="source_dir pattern"
posixshell_script_variable__get_input_variables "$input_var_list" "$@"
posixshell_script_variable__check_mandatory_variables "$input_var_list"
file=$(posixshell_io_filesystem__find_unique_file "$source_dir" "$pattern") || exit 1
```

## Rules

- Installed function names are prefixed: `posixshell_<folder>_<file>__<function>`
  (e.g. `set_json_value` of `io/files/json.sh` => `posixshell_io_files_json__set_json_value`).
  Always call the prefixed name; the index lists both. A short alias can be defined in the script if it is used a lot:
  `ok() { posixshell_io_terminal__print_in_yellow "$@"; }`.
- Many functions report errors with `exit 1` (`check_mandatory_*`, `ask_confirmation`), not `return`.
  Call them from the main script, not from a subshell `$(...)` if you need the script to stop.
- Functions that take an error logger take the NAME of a function (called with the faulty value as argument).
- Write scripts in POSIX sh (`#!/bin/sh`): no arrays, no `[[ ]]`, no `local`, no `${var//x/y}`.
  Known exceptions in the lib itself: `ask_confirmation` uses `[[ ]]`, `print_in_color` uses `local` (work in bash/dash/busybox in practice).
- Missing helper? Propose adding it to the lib (see AGENTS.md of the repo) instead of duplicating it in several scripts.

## Keeping the index up to date

`FUNCTIONS.md` is generated: `make docs` in the lib repo (script `release/gen_index.sh`).
This skill directory is symlinked from `~/.claude/skills/posix-shell-lib`.
