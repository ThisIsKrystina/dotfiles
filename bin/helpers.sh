#!/bin/bash

# @description - Check if a program or command exists first
# @example - `if has brew; then eval "$(brew shellenv)" fi
has() { 
local name=$1 #@
command -v "$name" &>/dev/null; 
}

#Checks before running a command
#@example 

run_if() { 
local name=$1 #@
has "$1" && shift && "$@"; 
}

# @description - loop through a directory of scripts to source in the current file
# @param string $dir - a path to a dir with glob pattern for script files
# @example - src_dir "~/projects/_active/dotfiles/bin/*.sh"
src_dir(){
# needs directory and glob pattern, like ~/src/repository-name/helpers/*.s
local dir=$1 #@
	for f in "$dir"; do
	    source "$f"
	done
}
