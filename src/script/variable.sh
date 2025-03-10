check_mandatory_variables() {
    __variables="$1"
    __print_error=$2

    for __var in $__variables; do
        eval __value=\$$__var
        if [ -z "$__value" ]; then
            if command -v "$__print_error" >/dev/null 2>&1; then
                eval "$__print_error \"$__var\""
            else
                echo "Error: variable '$__var' is empty or not set."
            fi
            exit 1
        fi
    done
}

# usage : get_input_variables "arg1 arg2 arg3" "$@"
# let's say you have a script with 3 args
# => script.sh arg1 arg2 arg3
# then in your script do
# input_var_list="arg1 arg2 arg3"
# get_input_variables "$input_var_list" "$@"
# this will intialize variables arg1 arg2 arg3 with their respective values
# if all input values must be provided, you can check that with
# check_mandatory_variables "$input_var_list"
get_input_variables() {
    __var_names="$1" # List of variable names in a single string (e.g., "var1 var2 var3")
    shift          # Shift to start processing arguments from $1 onwards
    # Convert the variable names into a list and iterate over them
    for __var_name in $__var_names; do
        eval "$__var_name=\${1:-}" # Assign each argument to a corresponding variable
        shift                    # Move to the next command-line argument
    done
}


is_number() {
    case "$1" in
    '' | *[!0-9]*) return 1 ;; # Not a number
    *) return 0 ;;             # Is a number
    esac
}

set_optional_positive_value() {
    __var_to_set_name=$1
    __optional_value=$2

    if [ ! -z "$__optional_value" ] && is_number "$__optional_value" && [ "$__optional_value" -gt 0 ]; then
        eval "$__var_to_set_name=\$__optional_value"
    fi

}
