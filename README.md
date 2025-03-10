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
