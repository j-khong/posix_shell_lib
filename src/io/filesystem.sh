

###############################################################################
# Function: find_unique_file
# 
# Description:
#   This function searches a directory for a file matching a regular
#   expression. If exactly one file matches, the function returns its name.
#   If no files or multiple files match, the function returns an error.
#
# Arguments:
#   $1 : Name of the directory to search in.
#   $2 : Regular expression to filter the files.
#
# Return Values:
#   0 : One file was found and is returned.
#   1 : The specified directory does not exist.
#   2 : No files match the regular expression.
#   3 : Multiple files match the regular expression.
#
# Example Usage:
#   result=$(find_unique_file "/path/to/directory" ".*\.txt$")
#   code=$?
#   if [ $code -eq 0 ]; then
#       echo "File found: $result"
#   else
#       if [ $code -eq 1 ]; then
#           echo "unknown folder"
#       elif [ $code -eq 2 ]; then
#           echo "no matches"
#       elif [ $code -eq 3 ]; then
#           echo "multiple matches"
#       fi
#   fi
#
###############################################################################

find_unique_file() {
    __ERR_MISSING_FOLDER=1
    __ERR_NO_MATCH=2
    __ERR_TO_MANY_MATCHES=3

    __folder="$1"
    __regexp="$2"
    __matches=""
    __count=0
    
    if [ ! -d "$__folder" ]; then
        return $____ERR_MISSING_FOLDER
    fi
    
    # searching files matching regexp
    for __file in "$__folder"/*; do
        if [ -f "$__file" ] && echo "$(basename "$__file")" | grep -q "$__regexp"; then
            __matches="$__file"
            __count=$((__count + 1))
        fi
    done
    
    if [ "$__count" -eq 1 ]; then
        echo "$__matches"
    elif [ "$__count" -eq 0 ]; then
        return $__ERR_NO_MATCH
    else
        return $__ERR_TO_MANY_MATCHES
    fi
}

check_mandatory_file() {
    __file_name=$1
    __print_error=$2

    if [ ! -f "$__file_name" ]; then
        if command -v "$__print_error" >/dev/null 2>&1; then
        # if [ -n "$__print_error" ]; then
            eval "$__print_error \"$__file_name\""
        else
            echo "Error: file '$__file_name' not found."
        fi
        exit 1
    fi
}

check_mandatory_folder() {
    __folder_name=$1
    __print_error=$2

    if [ ! -d "$__folder_name" ]; then
        if command -v "$__print_error" >/dev/null 2>&1; then
        # if [ -n "$__print_error" ]; then
            eval "$__print_error \"$__folder_name\""
        else
            echo "Error: folder '$__folder_name' not found."
        fi
        exit 1
    fi
}

get_file_line_count() {
    if [ -z "$1" ]; then echo "0"; return 1; fi
    if [ ! -f "$1" ]; then echo "0"; return 1; fi

    cat $1 | wc -l | tr -d ' '
}

read_file() {
    __file_path=$1
    __callback=$2
    
    if ! command -v "$__callback" >/dev/null 2>&1; then
        echo "Error: the provided callback function [$__callback] is missing"
        exit
    fi

    if [ -f "$__file_path" ]; then
        __total=$(get_file_line_count "$__file_path")
        __index=0
        while IFS= read -r __line; do
            eval "$__callback \"$__total\" \"$__index\" \"$__line\""
            __index=$((__index+1))
        done < "$__file_path"
    fi
}
