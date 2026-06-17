
# USAGE:
# Pass items separated by newlines to preserve spaces in values:
# 
# menu_items="key1=Display Value 1
# key2=Another Display Value
# key3=Third Option with Spaces"
# display "$menu_items" "callback_function" "exit_callback"
#
# - Items can be in "key=value" format where:
#   * key: short identifier passed to callback
#   * value: human-readable text displayed in menu (can contain spaces)
# - Items can also be simple strings without '=' separator
# - Navigation: arrow keys or j/k keys
# - Selection: Enter key
# - An "Exit" option is automatically added
#
# EXAMPLES:
# items="create=Create new file
# edit=Edit existing file  
# delete=Delete selected files"
# display "$items" "my_callback"

display() {
    __list_to_display="$1"
    __callback="$2"
    __on_exit_callback="$3"
    
    # Check if callback function exists
    if ! command -v "$__callback" >/dev/null 2>&1; then
        echo "Error: the provided callback function [$__callback] is missing"
        exit 1
    fi
    
    # Create temporary files for parsing
    temp_items=$(mktemp) && temp_display=$(mktemp) && raw_input=$(mktemp) \
        || { echo "Error: failed to create temp file"; exit 1; }

    # Ensure temp files are removed on exit or interruption
    trap 'rm -f "$temp_items" "$temp_display" "$raw_input"' EXIT INT TERM HUP

    # Add exit option first
    do_nothing="exit=🚪 Exit"
    
    # Process input line by line to preserve spaces
    # Write to temp file first to avoid subshell issues
    printf "%s\n%s\n" "$__list_to_display" "$do_nothing" > "$raw_input"
    
    # Now process line by line
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            echo "$line" >> "$temp_items"
            # Extract display value
            if echo "$line" | grep -q '='; then
                # Use sed to extract everything after the first =
                value=$(echo "$line" | sed 's/^[^=]*=//')
                echo "$value" >> "$temp_display"
            else
                echo "$line" >> "$temp_display"
            fi
        fi
    done < "$raw_input"

    # Use the file-based selection
    __select_option_from_file "$temp_display"
    choice=$?
    
    # Get the selected item
    selected_item=$(sed -n "$((choice + 1))p" "$temp_items")
    
    # Extract key from selected item
    if echo "$selected_item" | grep -q '='; then
        # Use sed to extract everything before the first =
        selected_key=$(echo "$selected_item" | sed 's/=.*//')
    else
        selected_key="$selected_item"
    fi

    # Clean up temp files now (trap remains as safety net)
    rm -f "$temp_items" "$temp_display" "$raw_input"
    trap - EXIT INT TERM HUP
    
    if [ "$selected_item" = "$do_nothing" ]; then
        if command -v "$__on_exit_callback" >/dev/null 2>&1; then
            eval "$__on_exit_callback"
            return
        fi
        return
    fi

    eval "$__callback \"$selected_key\""
}

# Menu selection function
# Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
#
#   Arguments   : list of options, maximum of 256
#                 "opt1" "opt2" ...
#   Return value: selected index (0 for opt1, 1 for opt2 ...)

__select_option_from_file() {
    # Select option from file (preserves spaces in values)
    __options_file="$1"
    __selected=0
    __total=$(wc -l < "$__options_file")
    
    # Save terminal settings
    __old_stty=$(stty -g 2>/dev/null) || __old_stty=""
    
    # Function to display menu
    __display_menu() {
        clear
        echo "Use j/k or arrow keys to navigate, Enter to select:"
        echo ""
        
        __idx=0
        while IFS= read -r opt; do
            if [ $__idx -eq $__selected ]; then
                printf "  > %s < \n" "$opt"
            else
                printf "    %s\n" "$opt"
            fi
            __idx=$((__idx + 1))
        done < "$__options_file"
    }
    
    # Function to read a single character
    __read_key() {
        if [ -n "$__old_stty" ]; then
            stty raw -echo 2>/dev/null
        fi
        __key=$(dd bs=1 count=1 2>/dev/null)
        if [ -n "$__old_stty" ]; then
            stty "$__old_stty" 2>/dev/null
        fi
        echo "$__key"
    }
    
    # Trap to restore terminal on exit
    trap 'if [ -n "$__old_stty" ]; then stty "$__old_stty" 2>/dev/null; fi; echo; exit' INT TERM
    
    # Main loop
    while true; do
        __display_menu
        
        __key=$(__read_key)
        
        # Handle different key inputs
        case "$__key" in
            # Enter key (newline or carriage return)
            "$(printf '\n')" | "$(printf '\r')" | '')
                break
                ;;
            # 'j' key or down arrow
            'j')
                __selected=$((__selected + 1))
                if [ $__selected -ge $__total ]; then
                    __selected=0
                fi
                ;;
            # 'k' key or up arrow  
            'k')
                __selected=$((__selected - 1))
                if [ $__selected -lt 0 ]; then
                    __selected=$((__total - 1))
                fi
                ;;
            # ESC sequence (arrow keys)
            "$(printf '\033')")
                # Read next two characters for arrow sequence
                seq1=$(__read_key)
                seq2=$(__read_key)
                if [ "$seq1" = "[" ]; then
                    case "$seq2" in
                        'A') # Up arrow
                            __selected=$((__selected - 1))
                            if [ $__selected -lt 0 ]; then
                                __selected=$((__total - 1))
                            fi
                            ;;
                        'B') # Down arrow
                            __selected=$((__selected + 1))
                            if [ $__selected -ge $__total ]; then
                                __selected=0
                            fi
                            ;;
                    esac
                fi
                ;;
        esac
    done
    
    # Restore terminal settings
    if [ -n "$__old_stty" ]; then
        stty "$__old_stty" 2>/dev/null
    fi
    
    # Clear screen and show final selection
    clear
    __selected_value=$(sed -n "$((__selected + 1))p" "$__options_file")
    # echo "Selected: $__selected_value"
    
    return $__selected
}

