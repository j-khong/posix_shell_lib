###############################################################################
# Function: set_json_value
#
# Description:
#   Updates the value associated with a specified key in a JSON file.
#
# Arguments:
#   $1 - Path to the JSON file where the key-value pair should be updated.
#   $2 - The key whose value needs to be updated.
#   $3 - The new value to be set for the key.
#
# Returns:
#   On success: 
#       - Updates the JSON file in place
#   On failure:
#       - Returns error code 1 if the sed command fails.
#
# Example Usage:
#   set_json_value "config.json" "username" "new_user"
#   code=$?
#   if [ "$code" -eq 0 ]; then
#       echo "Update successful"
#   else
#       echo "Error code $code"
#   fi
#
# Notes:
#   - Special characters in the key and value are escaped to avoid issues with sed.
#   - A backup of the original file is created with a `.bak` extension before updating.
#   - The backup file is removed if the update is successful.
###############################################################################

set_json_value() {
    __json_file="$1"
    __key="$2"
    __value="$3"

    # Escape special characters in the key and value
    __escaped_key=$(printf '%s' "$__key" | sed 's/[\/&]/\\&/g')
    __escaped_value=$(printf '%s' "$__value" | sed 's/[\/&]/\\&/g')

    # Use sed to search for the key and replace its value
    sed -i.bak -e "s/\"$__escaped_key\" *: *\"[^\"]*\"/\"$__escaped_key\": \"$__escaped_value\"/" "$__json_file"

    if [ $? -eq 0 ]; then
        rm "$__json_file.bak"
    else
        return 1
    fi
}

###############################################################################
# Function: extract_json_value
#
# Description:
#   This function extracts the value associated with a specified key
#   from a given JSON file. The function is POSIX-compliant and does 
#   not require any external dependencies or non-standard utilities.
#
# Arguments:
#   $1 - The path to the JSON file to be read.
#   $2 - The key whose value should be extracted from the JSON file.
#
# Returns:
#   On success: 
#       - Prints the value associated with the specified key.
#       - Returns 0.
#   On failure:
#       - Prints an error message and returns:
#           1 if the file does not exist.
#           2 if the key is not found or has no value.
#
# Example Usage:
#   value=$(extract_json_value "data.json" "username")
#   code=$?
#   if [ "$code" -eq 0 ]; then
#       echo "Username: $value"
#   else
#       echo "Failed to retrieve the username."
#   fi
#
# Notes:
#   - This function assumes the JSON file has a simple structure
#     and does not handle nested JSON objects or arrays.
#   - The function expects the key-value pairs to be in the format:
#       "key": "value"
###############################################################################
extract_json_value() {
    __json_file="$1"
    __key="$2"

    # Check if the file exists
    if [ ! -f "$__json_file" ]; then
        return 1
    fi

    # Extract the value associated with the key
    __value=$(grep -o "\"$__key\": *\"[^\"]*\"" "$__json_file" | sed "s/\"$__key\": *\"//" | sed 's/\"$//')

    # Check if the value is empty (key not found)
    if [ -z "$__value" ]; then
        return 2
    fi

    # Return the value
    echo "$__value"
}
