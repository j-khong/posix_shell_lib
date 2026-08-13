###############################################################################
# Function: is_valid
#
# Description:
#   Check that a string is a valid semantic version
#   (MAJOR.MINOR.PATCH with optional pre-release and build metadata)
#
# Arguments:
#   $1 - The version string to validate
#   $2 - (optional) The name of a function used to log the error.
#        If provided and it is a command, it is called with the version
#        as argument; otherwise the default error message is printed.
#
# Returns:
#   On success:
#       - Returns 0 if the version matches the semver format
#   On failure:
#       - Logs the error (custom function or default message)
#       - Returns 1
#
# Example Usage:
#   is_valid "1.2.3"
#   is_valid "1.2.3" my_log_function
#
# Notes:
#   - POSIX compliant: relies on `grep -E` instead of the bash `[[ =~ ]]`
#     construct so the function stays portable across shells.
###############################################################################
is_valid() {
    __version=$1
    __print_error=$2

    if ! echo "$__version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'; then
        if command -v "$__print_error" >/dev/null 2>&1; then
            eval "$__print_error \"$__version\""
        else
            echo "❌ version '$__version' is not a semver format (ex: 1.2.3)"
        fi
        return 1
    fi

    return 0
}

###############################################################################
# Function: calculate_next_version
#
# Description:
#   Calculate the next semantic version based on user input
#
# Arguments:
#   $1 - The semver to increment
#   $2 - The versioning option (patch, minor, or major)
#
# Returns:
#   On success: 
#       - The calculated next version is printed to the standard output
#   On failure:
#       - Returns error code:
#           1 if the file semver format is incorrect.
#           2 if the versioning option is incorrect
#
# Example Usage:
#   value=$(calculate_next_version "1.2.3" "minor")
#   code=$?
#   if [ "$code" -eq 0 ]; then
#       echo "next version is $value"
#   else
#       echo "error code $code"
#   fi
#
# Notes:
#   - some worthy notes
###############################################################################
calculate_next_version() {
    __current_version=$1
    __new_version_type=$2

    set -- $(echo "$__current_version" | sed 's/\./ /g')

    if [ "$#" -ne 3 ]; then
        return 1
    fi
    __major_digit="$1"
    __minor_digit="$2"
    __patch_digit="$3"

    case $__new_version_type in
        "patch")
            __version_root="$__major_digit.$__minor_digit"
            __new_patch_digit=$(($__patch_digit + 1))
            __next_version="$__version_root.$__new_patch_digit"
        ;;
        "minor")
            __new_minor_digit=$(($__minor_digit + 1))
            __next_version="$__major_digit.$__new_minor_digit.0"
        ;;
        "major")
            __new_major_digit=$(($__major_digit + 1))
            __next_version="$__new_major_digit.0.0"
        ;;
        *)
            return 2
        ;;
    esac

    echo "$__next_version"
}
