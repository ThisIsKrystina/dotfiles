#!/bin/bash

# @description - Check if a program or command exists first
# @example - `if has brew; then eval "$(brew shellenv)" fi
has() { 
local name=$1 #@
command -v "${name}" &>/dev/null; 
}

#Checks before running a command
#@example 

run_if() { 
local name=$1 #@
has "$1" && shift && "$@"; 
}

# @description - Source every *.<ext> script in a directory, with optional skips.
# @param string $1 - directory to scan (required)
# @param string $2 - file extension WITHOUT the dot (default: sh)
# @param string ... - optional filenames to skip, e.g. 00-config.env
# @example - src_dir ~/Projects/_active/dotfiles/bin sh 01-helpers.sh
src_dir() {
	# Pass a DIRECTORY, not a glob. A glob (*.sh) expands in the CALLER's
	# shell first, so the function would only ever see the first match.
	local dir="${1:?src_dir: need a directory path}"
	local ext="${2:-sh}"
	local excludes=("${@:3}") # everything after ext = files to skip

	local file base skip ex
	for file in "${dir}"/*."${ext}"; do
		# If nothing matches, the glob stays literal — skip that phantom entry
		[[ -e "${file}" ]] || continue

		base="${file##*/}" # strip the path, keep just the filename
		skip=""
		for ex in "${excludes[@]}"; do
			[[ "${base}" == "${ex}" ]] && { skip=1; break; }
		done
		[[ -n "${skip}" ]] && continue

		source "${file}"
	done
}
