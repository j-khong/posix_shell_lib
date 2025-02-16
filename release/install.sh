#!/bin/sh
set -e

version=$1

lib_name=posix_shell_lib
repo="j-khong/$lib_name"
last_version=$(curl -s "https://api.github.com/repos/$repo/tags" | grep '"name"' | head -n 1 | awk -F '"' '{print $4}')

[ -z "$version" ] && { version=$last_version; }

install_folder_name=".$lib_name"
root_install_folder=~/$install_folder_name
mkdir -p "$root_install_folder"
installed_version_folder=$root_install_folder/$version
if [ -d "$installed_version_folder" ]; then 
    echo "lib v.$version is already installed => $installed_version_folder"
    exit 0
fi

URL="https://github.com/${repo}/releases/download/${version}/${lib_name}-${version}.tar.gz"

if curl -o /dev/null -s -w "%{http_code}" -L "$URL" | grep -q "^2"; then
    :
else
    echo "❌ the version you provided [$version] does not exist"
    exit 1
fi

echo "⇣ downloading tar file"
curl -sL "$URL" -o ${lib_name}.tar.gz

echo "📦 installing package"
tar -xzf ${lib_name}.tar.gz -C "$root_install_folder"
rm ${lib_name}.tar.gz

if [ "$version" == "$last_version" ]; then
    symlink_name="$root_install_folder/latest"
    if [ -L "$symlink_name" ]; then rm "$symlink_name"; fi
    ln -s "$installed_version_folder" "$symlink_name"
fi

echo "✅ installation done !"

echo ""

echo "you can import a specific lib file in your scripts with :"
echo ". $HOME/$install_folder_name/$version/{the_file_path}"
if [ "$version" == "$last_version" ]; then
    echo "or"
    echo ". $HOME/$install_folder_name/latest/{the_file_path}"
fi