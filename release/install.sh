#!/bin/sh
set -e

dest_folder=$1
version=$2

lib_name=posix_shell_lib
repo="j-khong/$lib_name"
last_version=$(curl -s "https://api.github.com/repos/$repo/tags" | grep '"name"' | head -n 1 | awk -F '"' '{print $4}')

[ -z "$dest_folder" ] && { dest_folder=$HOME; }
[ -z "$version" ] && { version=$last_version; }

install_folder_name=".$lib_name"
root_install_folder=$dest_folder/$install_folder_name
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

file_to_edit=$root_install_folder/$version/import.sh
if [ -f "$file_to_edit" ]; then
    echo "__install_path=$dest_folder" > "$file_to_edit.tmp"
    cat "$file_to_edit" >> "$file_to_edit.tmp"
    mv "$file_to_edit.tmp" "$file_to_edit"
fi

echo "✅ installation done !"

echo ""

echo "you can import a specific lib file in your scripts with :"
echo ". $root_install_folder/$version/{the_file_path}"
if [ "$version" == "$last_version" ]; then
    echo "or"
    echo ". $root_install_folder/latest/{the_file_path}"
fi