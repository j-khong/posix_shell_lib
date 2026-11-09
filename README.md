# posix_shell_lib

## install
```sh
# install the latest version (in $HOME by default)
curl -sL  https://raw.githubusercontent.com/j-khong/posix_shell_lib/refs/heads/main/release/install.sh | sh

# install the latest version in a specific folder
specific_folder=/tmp
curl -sL  https://raw.githubusercontent.com/j-khong/posix_shell_lib/refs/heads/main/release/install.sh | sh -s -- "$specific_folder"

# install a specific version
specific_version=0.0.6
curl -sL  https://raw.githubusercontent.com/j-khong/posix_shell_lib/refs/heads/main/release/install.sh | sh -s -- "$HOME" "$specific_version"
```

## usage
```sh
#!/bin/sh
# import every function (or a single file, e.g. $HOME/.posix_shell_lib/latest/io/filesystem.sh)
. "$HOME/.posix_shell_lib/latest/import.sh"

posixshell_io_terminal__print_in_red "hello"
```
Installed functions are prefixed with `posixshell_<folder>_<file>__`.
The list of available functions is in [FUNCTIONS.md](.claude/skills/posix-shell-lib/FUNCTIONS.md) (also shipped in each release).

## for AI agents
The repo ships a Claude Code skill (`.claude/skills/posix-shell-lib`) telling agents to use this lib when writing shell scripts. It is shipped in each release (`skill/` folder). To link it into `~/.claude/skills` at install time:
```sh
curl -sL https://raw.githubusercontent.com/j-khong/posix_shell_lib/refs/heads/main/release/install.sh | INSTALL_SKILL=1 sh
```
From a clone of the repo:
```sh
ln -s "$(pwd)/.claude/skills/posix-shell-lib" ~/.claude/skills/posix-shell-lib
```
Contributors/agents working on the lib itself: see [AGENTS.md](AGENTS.md).
