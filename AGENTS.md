# posix_shell_lib

Library of reusable **POSIX sh** functions (files, JSON, terminal, variables, semver), meant to be sourced by other shell scripts.
It is the reference for shell scripting: agents writing scripts elsewhere should use the `posix-shell-lib` skill (`.claude/skills/posix-shell-lib/`), which contains the function index.

## Layout

- `src/<folder>/<file>.sh`: the functions, grouped by domain (`io/`, `script/`, `semver.sh`...).
- `tests/<same path as src>/<function>_test.sh`: one test file per function, using `tests/assert.sh`.
- `release/build.sh`: generates `dist/<version>/` by prefixing every function with its namespace.
- `release/gen_index.sh`: generates the function index (`make docs`).
- `release/install.sh`: end-user installer (downloads the GitHub release into `~/.posix_shell_lib`).

## Commands

- `make tests`: build, generate `tests/config.sh`, run the tests on alpine/debian/ubuntu (Docker).
- `sh tests/run_tests.sh`: run the tests locally (fast, no Docker).
- `make docs`: regenerate `.claude/skills/posix-shell-lib/FUNCTIONS.md`. Run it after adding/changing a function or its header, and commit the result.
- `make build`: package the lib (needs a git tag).

## Conventions

- POSIX sh only (`#!/bin/sh`): no arrays, no `[[ ]]`, no `local`, no bashisms.
- Function variables are prefixed with `__` (no `local` in POSIX sh) to avoid collisions with the caller's variables.
- Every public function has a comment block just above it, in this format (the index is generated from it):
  ```
  ###############################################################################
  # Function: name
  #
  # Description:
  #   One or two sentences.
  #
  # Arguments:
  #   $1 - ...
  #
  # Returns:
  #   ...
  #
  # Example Usage:
  #   ...
  ###############################################################################
  ```
- Functions starting with `__` are private and excluded from the index.
- Error reporting: optional last argument = NAME of a logger function, with a default message otherwise.
- Build caveat: `build.sh` rewrites function names by text substitution, so a function name must not be a substring of another identifier used in the sources (comments included).
- Every new function needs a test in `tests/`.

## Release

Every PR title must start with `[patch]`, `[minor]` or `[major]` (checked by CI). Merging to `main` auto-tags the next version and triggers the GitHub release. Never tag manually.
