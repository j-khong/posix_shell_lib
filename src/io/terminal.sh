# Description:
#   Print a text in the given ANSI color, followed by a newline.
#
# Arguments:
#   $1 - ANSI color escape sequence
#   $2 - Text to print
print_in_color() {
    local __STOP_COLOR="\\e[m"
    local __COLOR="$1"
    local __TEXT="$2"
    printf "%b%s%b\n" "$__COLOR" "$__TEXT" "$__STOP_COLOR"
}

# Description:
#   Print a text in red.
#
# Arguments:
#   $1 - Text to print
print_in_red() {
    __RED='\033[0;31m'
    print_in_color "$__RED" "$1"
    
    # print_in_color "\\033[31m" "$1"
    # print_in_color "\\033[0;31m" "$1"
}

# Description:
#   Print a text in yellow.
#
# Arguments:
#   $1 - Text to print
print_in_yellow() {
    print_in_color "\\033[1;33m" "$1"
}

# Description:
#   Print a text in orange.
#
# Arguments:
#   $1 - Text to print
print_in_orange() {
    print_in_color "\\033[0;033m" "$1"
}

# Description:
#   Ask the user to type a given string to continue; exit with code 1 otherwise.
#
# Arguments:
#   $1 - String the user must type
#   $2 - (optional) Name of a function used to print the prompt header
ask_confirmation() {
    __confirm_string=$1
    __print_header=$2

    if command -v "$__print_header" >/dev/null 2>&1; then
        eval "$__print_header \"$__confirm_string\""
    else
        echo "***************************************************************"
        echo "* enter $__confirm_string to continue or any other key to exit"
        echo "***************************************************************"
    fi

    read __response
    if [[ "$__confirm_string" != "$__response" ]]; then
        echo exiting...
        exit 1
    fi
}

