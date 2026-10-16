#!/bin/bash

_ERR_MSG=""
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
error_handler() {
local line_number=$1
local error_code=$2
local command="$3"
local msg=""
# set error message
[[ -n "${_ERR_MSG}" ]] && msg=" — ${_ERR_MSG}"
local message="${BOLD}line ${line_number}:${RESET} '${command}' failed (${BOLD}code:${RESET} ${error_code})${msg}"
    # Print to stderr (>&2) with red bold color, then reset
    printf "${RED}${BOLD}[ERROR]${RESET} %s\n" "${message}" >&2
}

# --- Explicit wrapper (works in both modes, no trap needed) ---
die_on_fail() {
    local msg="$1"; shift
    "$@" || {
        echo "ERROR: ${msg} (command: $*)" >&2
        return $?
    }
}

# --- Strict mode: non-interactive only ---
case $- in
  *i*)
    # Interactive shell — just make functions available, no side effects
    ;;
  *)
    set -Eeuo pipefail
    shopt -s inherit_errexit
    trap 'error_handler ${LINENO} $? "$BASH_COMMAND"' ERR
    ;;
esac
