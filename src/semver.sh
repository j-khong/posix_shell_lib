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
