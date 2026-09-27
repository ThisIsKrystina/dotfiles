#!/bin/bash

# @example error "This is an error!"

# Only set colors if stderr is a terminal and NO_COLOR is not set
if [[ -t 2 ]] && [[ -z "${NO_COLOR:-}" ]]; then
    RED=$(tput setaf 1)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    RED=''
    BOLD=''
    RESET=''
fi

# Reusable error function
error() {
    local message="${1:-Unknown Error}"
    # Print to stderr (>&2) with red bold color, then reset
    printf "${RED}${BOLD}[ERROR]${RESET} %s\n" "$message" >&2
}   