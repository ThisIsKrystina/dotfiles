#!/bin/bash

# Credit: https://github.com/jmagar/claude-homelab/blob/main/docs/references/security-patterns.md

# @description Sanitizes user input and remove dangerous characters
# @example user_query=$(sanitize_input "$1")
sanitize_input() {
    local input="$1"
    echo "$input" | sed 's/[;&|`$(){}[\]<>\\]//g' | tr -d '\n\r'
}


## Command Injection Prevention

# @description Never directly interpolate user input into shell commands or URLs.
# DANGEROUS curl "https://api.example.com/search?q=$user_input"

# SAFE - Properly escaped and quoted query=$(printf '%s' "$user_input" | jq -sRr @uri)curl "https://api.example.com/search?q=${query}"


# URL Encoding

# @description Always URL-encode user input when building API requests.
# @example
# search_term=$(url_encode "user's search & query")
# curl "https://api.example.com/search?q=${search_term}"
url_encode() {
    local string="$1"
    printf '%s' "$string" | jq -sRr @uri
}

# @description -  Validate file paths to prevent directory traversal attacks.
# @example - safe_path=$(validate_path "$user_file" "/allowed/directory") || exit 1

validate_path() {
    local file_path="$1"
    local base_dir="$2"

    # Resolve to absolute path
    local abs_path=$(realpath -m "$file_path" 2>/dev/null)
    local abs_base=$(realpath "$base_dir")

    # Check if path starts with base directory
    if [[ "$abs_path" != "$abs_base"* ]]; then
        log_error "Invalid path: $file_path (outside base directory)"
        return 1
    fi

    echo "$abs_path"
}


## JSON Response Parsing

# @description validate JSON structure before parsing.
# @example response=$(curl -s https://api.example.com/data)
# value=$(parse_json_safely "$response" "data.field") || exit 1

parse_json_safely() {
    local json="$1"
    local key="$2"

    # Check if valid JSON
    if ! echo "$json" | jq empty 2>/dev/null; then
        log_error "Invalid JSON response"
        return 1
    fi

    # Extract value
    echo "$json" | jq -r ".$key // empty"
}