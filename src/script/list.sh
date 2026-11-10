# Description:
#   Check that a value is in a space separated list (return 0 if found, 1 otherwise).
#
# Arguments:
#   $1 - The list, e.g. "val1 val2 val3"
#   $2 - The value to look for
#
# list="val1 val2 val3"
# not working with list=(val1 val2 val3)
# => test with every val
is_in_list() {
    __list="$1"
    __value="$2"

    for __item in $__list; do
        if [ "$__item" = "$__value" ]; then
            return 0
        fi
    done

    return 1
}
