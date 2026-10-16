#!/bin/bash

source "${BASH_SOURCE[0]%/*}/00-config.env"
# Jump to repo and output status
repo() {
local dir=${REPO_HOME}
local repo_name=$1

# @todo add error handling

cd "${dir:-${HOME}}/${repo_name}" && git status -sb && ll
      }
      

git_new(){
  # Check if project name is provided
  if [ -z "$1" ]; then
      echo "${BOLD}Usage:${RESET} git_new <project-name>"
      exit 1
  fi
  
  REPO_NAME=$1
  PROJECT_NAME="${REPO_NAME//-/ }"   # hyphens → spaces
  PROJECT_NAME="${PRETTY_NAME^}"
  REPO_PATH="${REPO_HOME}/${PROJECT_NAME}"
   TEMPLATE_URL="https://github.com/ThisIsKrystina/gh-template"
  
  # Clone template into new folder
  git clone "$TEMPLATE_URL" "$REPO_PATH"
  cd "$REPO_PATH"
  # Wipe git history, re-init fresh
  rm -rf .git
  git init
  
  # Customize (replace placeholders, etc.)
  PLACEHOLDER_REPO='/\{+REPO_NAME\}+/gm'
  sed -i "s/__REPO_NAME__/$REPO_NAME/g" README.md
  
  git add .
  git commit -m "chore: init repo"
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
