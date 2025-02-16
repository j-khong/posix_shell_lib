#!/bin/bash


lib_name="$1"
output_dir="$2"

if [ -z "$lib_name" ] || [ -z "$output_dir" ]; then
    echo "Usage: $0 <lib_name> <output_dir>"
    exit 1
fi

is_absolute_path() {
    case "$1" in
        /*) return 0 ;;  # Absolute path
        "~"*) return 0 ;;  # Home directory path
        *) return 1 ;;  # Not an absolute path
    esac
}

expand_path() {
    case "$1" in
        "~"*) echo "$HOME${1#\~}" ;;
        *) echo "$1" ;;
    esac
}

# Expand the path first
expanded_dir=$(expand_path "$output_dir")

if is_absolute_path "$expanded_dir"; then
    echo "output_dir is an absolute path."
else
    echo "output_dir [$expanded_dir] is not an absolute path."
    exit 1
fi

if [ ! -d "$output_dir" ]; then mkdir -p "$output_dir"; fi

process_file() {
    filepath="$1"
    output_dir="$2"
    
    # Extract the relative path and filename without extension
    relative_path="${filepath#/}"
    filename=$(basename -- "$relative_path")
    filename_without_ext="${filename%.sh}"
    version=$(echo "$relative_path" | cut -d'/' -f1)
    no_version=$(echo "$relative_path" | cut -d'/' -f2-)
    # echo "filepath: $filepath"
    # echo "relative_path: $relative_path"
    # echo "filename: $filename"
    # echo "filename_without_ext: $filename_without_ext"
    # echo "version: $version"
    # echo "no_version: $no_version"


    namespace_sep="_"
    namespace_delim="__"
    # namespace_delim="#"
    # Prepare the namespace based on the path
    namespace=$(dirname "$no_version" | tr '/' "$namespace_sep")
    if [ "$namespace" != "." ]; then
        namespace="${namespace}${namespace_sep}${filename_without_ext}"
    else
        namespace="${filename_without_ext}"
    fi
    namespace="posixshell$namespace_sep$namespace"

    # Create the output directory structure
    output_path="$output_dir/$(dirname "$relative_path")"
    mkdir -p "$output_path"

    # Process the file and prefix the functions
    output_file="$output_path/$filename"

    original_funcs=()
    prefixed_funcs=()

    # First pass: Identify functions and build arrays of original and prefixed names
    while IFS= read -r line; do
        if [[ "$line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*\(\)\ \{ ]]; then
            func_name=$(echo "$line" | awk '{print $1}' | sed 's/()//')
            original_funcs+=("$func_name")
            full_func_name="${namespace}${namespace_delim}${func_name}"
            prefixed_funcs+=("${full_func_name}")
            line="${full_func_name}() {"
        fi
        echo "$line" >> "$output_file.tmp"
    done < "$filepath"

    echo "#!/bin/sh" > "$output_file"
    # Second pass: Replace function calls with prefixed names
    while IFS= read -r line; do
        for ((i=0; i<${#original_funcs[@]}; i++)); do
            orig="${original_funcs[$i]}"
            pref="${prefixed_funcs[$i]}"
            # Replace only if the original function name is not part of the new one
            if [[ "$line" != *"$pref"* ]]; then
                line="${line//"$orig"/$pref}"
            fi
        done
        echo "$line" >> "$output_file"
    done < "$output_file.tmp"

    # Clean up the temporary file
    rm "$output_file.tmp"
}


source_dir="src"

work_dir="/tmp/workdir-$(date +%s)"
if [ -d "$work_dir" ]; then rm -fr "$work_dir"; fi
mkdir "$work_dir" && \
cp -fr "$source_dir" "$work_dir/$lib_name" && \
cd "$work_dir" && \

# Export the function to use it in find -exec
export -f process_file && \

# Find and process all .sh files
# cd "$lib_name"
# find . -name "*.sh" -exec bash -c 'process_file "$0" "$1"' {} "$output_dir" \;
find "$lib_name" -name "*.sh" -exec bash -c 'process_file "$0" "$1"' {} "$output_dir" \; && \

echo "Processing complete." && \
echo "version $lib_name as been generated." && \
echo "Check the output directory: $output_dir" && \

cd .. && \
rm -fr "$work_dir" || echo '❌ error'
