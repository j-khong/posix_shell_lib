###############################################################################
# Function: parse_arguments
#
# Description:
#   Generic CLI argument parsing driven by a conf file. Each value is written
#   to the global variable named in the 'variable' column of the conf file
#   (the default is applied if the option is absent).
#
# Arguments:
#   $1 - Path of the conf file
#   $2 - Program name, displayed in the usage
#   $@ - The arguments to parse (usually "$@" of the calling script)
#
# Returns:
#   On success:
#       - Returns 0, the variables are set
#   On failure (unknown/invalid option, missing value, wrong number of
#   positional arguments, bad conf file):
#       - Prints the error and the usage on stderr, returns 1
#   With -h or --help:
#       - Prints the usage and exits with code 0
#
# Example Usage:
#   . "$HOME/.posix_shell_lib/latest/io/terminal/cli.sh"
#   parse_arguments "$script_dir/my-script.cli.conf" "$0" "$@" || exit 1
#   echo "$project"
#
# Notes:
#   - Conf file format, one declaration per line ('#' = comment):
#       type | short | long | variable | default | description
#     with type being:
#       opt   option with a value   -p value | --project value | --project=value
#       flag  boolean option        variable = 1 if present, otherwise the default
#       pos   required positional argument, assigned in declaration order
#   - Options are accepted anywhere, '--' ends the options.
###############################################################################
parse_arguments() {
    [ -f "$1" ] || { echo "error: conf file not found: $1" >&2; return 1; }
    __spec=$(__load_spec "$1")
    __prog="$2"
    shift 2

    # validate variable names + initialize to default values
    __pos_vars=""
    __n_pos=0
    while IFS='|' read -r __t __s __l __v __d __desc; do
        case "$__t" in opt|flag|pos) ;; *) echo "error: unknown type: '$__t'" >&2; return 1 ;; esac
        case "$__v" in
            ''|[0-9]*|*[!A-Za-z0-9_]*) echo "error: invalid variable name: '$__v'" >&2; return 1 ;;
        esac
        if [ "$__t" = "pos" ]; then
            __pos_vars="$__pos_vars $__v"
            __n_pos=$((__n_pos + 1))
        else
            eval "$__v=\$__d"
        fi
    done <<EOF
$__spec
EOF

    # read the arguments: options are consumed, positionals are put back at
    # the end of "$@" (rotation) to be assigned afterwards
    __n_args=$#
    __only_pos=0
    while [ "$__n_args" -gt 0 ]; do
        __arg="$1"
        shift
        __n_args=$((__n_args - 1))

        if [ "$__only_pos" -eq 1 ]; then
            set -- "$@" "$__arg"
            continue
        fi

        case "$__arg" in
            --) __only_pos=1 ;;
            -h|--help) __usage "$__spec" "$__prog"; exit 0 ;;
            --?*=*)
                __name="${__arg#--}"; __name="${__name%%=*}"
                __value="${__arg#*=}"
                __find_opt "$__spec" long "$__name"
                [ "$__found_type" = "opt" ] \
                    || { echo "error: unknown option or option without value: --$__name" >&2; __usage "$__spec" "$__prog" >&2; return 1; }
                eval "$__found_var=\$__value"
                ;;
            --?*|-?)
                case "$__arg" in --*) __kind=long; __name="${__arg#--}" ;; *) __kind=short; __name="${__arg#-}" ;; esac
                __find_opt "$__spec" "$__kind" "$__name"
                case "$__found_type" in
                    flag) eval "$__found_var=1" ;;
                    opt)
                        [ "$__n_args" -ge 1 ] \
                            || { echo "error: $__arg expects a value" >&2; __usage "$__spec" "$__prog" >&2; return 1; }
                        __value="$1"
                        shift
                        __n_args=$((__n_args - 1))
                        eval "$__found_var=\$__value"
                        ;;
                    *) echo "error: unknown option: $__arg" >&2; __usage "$__spec" "$__prog" >&2; return 1 ;;
                esac
                ;;
            -*) echo "error: unknown option: $__arg" >&2; __usage "$__spec" "$__prog" >&2; return 1 ;;
            *) set -- "$@" "$__arg" ;;
        esac
    done

    if [ $# -ne "$__n_pos" ]; then
        echo "error: $__n_pos argument(s) expected, $# received" >&2
        __usage "$__spec" "$__prog" >&2
        return 1
    fi

    for __v in $__pos_vars; do
        __value="$1"
        shift
        eval "$__v=\$__value"
    done
}


# trim leading/trailing whitespace
__trim() {
    printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

# reads the conf file, strips comments/empty lines, trims each field
# output: lines "type|short|long|variable|default|description"
__load_spec() {
    while IFS='|' read -r __t __s __l __v __d __desc || [ -n "$__t" ]; do
        __t=$(__trim "$__t")
        case "$__t" in ''|'#'*) continue ;; esac
        printf '%s|%s|%s|%s|%s|%s\n' \
            "$__t" "$(__trim "$__s")" "$(__trim "$__l")" "$(__trim "$__v")" \
            "$(__trim "$__d")" "$(__trim "$__desc")"
    done < "$1"
}

# usage: __usage <spec> <prog>
__usage() {
    __spec="$1"
    __prog="$2"

    __synopsis=""
    __details=""
    while IFS='|' read -r __t __s __l __v __d __desc; do
        case "$__t" in
            pos) __synopsis="$__synopsis <$__v>" ; __details="$__details
  $(printf '%-24s' "<$__v>") $__desc" ;;
            opt|flag)
                __names=""
                [ -n "$__s" ] && __names="-$__s"
                [ -n "$__l" ] && __names="${__names:+$__names, }--$__l"
                __short_form="${__s:+-$__s}"
                __short_form="${__short_form:---$__l}"
                if [ "$__t" = "opt" ]; then
                    __names="$__names <value>"
                    __short_form="$__short_form <value>"
                fi
                __synopsis="$__synopsis [$__short_form]"
                __details="$__details
  $(printf '%-24s' "$__names") $__desc${__d:+ (default: $__d)}"
                ;;
        esac
    done <<EOF
$__spec
EOF
    printf 'usage: %s%s\n%s\n  %-24s %s\n' "$__prog" "$__synopsis" "$__details" "-h, --help" "show this help"
}

# looks up an option in the spec: __find_opt <spec> <short|long> <name>
# sets __found_type and __found_var (empty if not found)
__find_opt() {
    __found_type=""
    __found_var=""
    while IFS='|' read -r __t __s __l __v __d __desc; do
        case "$__t" in opt|flag) ;; *) continue ;; esac
        if { [ "$2" = "short" ] && [ -n "$__s" ] && [ "$__s" = "$3" ]; } \
            || { [ "$2" = "long" ] && [ -n "$__l" ] && [ "$__l" = "$3" ]; }; then
            __found_type="$__t"
            __found_var="$__v"
            return 0
        fi
    done <<EOF
$1
EOF
    return 0
}

