#!/bin/bash
set -e
set -o pipefail # trace errors through piped functions
# trace function errors

error_handler() {
  result=$("$@" 2>&1)
  if [ $? -ne -0 ]; then
  echo "Error: $result"
  exit 1
  fi
}
label(){
	local divider="========"
	local label="$1"
	echo "$divider $label $divider"
}

check_claude_code_processes() {
  label "DAEMON STATUS"
  claude daemon status
printf '\n'
  label "ACTIVE AGENTS"
  claude agents --json
printf '\n'
label "WORKTREES"
git worktree list
printf '\n'
  label "ORPHANED PROCESSES"
  ps -eo pid, etime, %cpu,command | pgrep -i '[c]laude'
}
# bkgProcess='claude daemon status | cat <(label "DAEMON STATUS") -'

gitChangedFiles='git diff --stat | cat <(label "CHANGED FILES") -'
gitRecentCommits='git log --oneline -5 | cat <(label "RECENT COMMITS") -'
gitStatus=''

# Start the output
echo "Current session state..."
echo 
printf '\n'
eval "$gitChangedFiles"
printf '\n'
eval "$gitRecentCommits"
printf '\n'
check_claude_code_processes
printf '\n'
# eval "$bkgProcess"