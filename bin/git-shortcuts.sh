#!/bin/bash

source "${BASH_SOURCE[0]%/*}/00-config.env"
# Jump to repo and output status
repo() {
local dir=${REPO_HOME}
local repo_name=$1

# @todo add error handling

cd "${dir:-${HOME}}/${repo_name}" && git status -sb && ll
      }
      
# --- Git log: fzf picks commit, preview shows delta, Enter shows full diff ---


glog() {
  git log --oneline --color=always | \
  fzf --ansi --preview "git show --color=always {1} | delta --width ${FZF_PREVIEW_COLUMNS:-${COLUMNS}}" \
  | xargs -r -I{} git show --color=always {} | delta
}

# --- Git status: fzf picks changed file, preview shows delta diff, Enter opens editor ---
gdiff() {
  git diff --name-only | \
  fzf --preview "git diff --color=always -- {} | delta --width ${FZF_PREVIEW_COLUMNS:-${COLUMNS}}" \
  | xargs -r "${EDITOR:-nano}"
}

# --- Git staged diff ---
gdiffs() {
  git diff --staged --name-only | \
  fzf --preview "git diff --staged --color=always -- {} | delta --width ${FZF_PREVIEW_COLUMNS:-${COLUMNS}}" \
  | xargs -r "${EDITOR:-nano}"
}