#!/bin/bash

# Type "where" to see where you are + what's here, in one shot
where() { printf '\n%s\n\n' "$(pwd)"; eza -la --git --group-directories-first --icons=always --hyperlink=always; }

# Auto-list after every cd (the big one for ADHD)
cd() { builtin cd "$@" && eza -la --git --group-directories-first --icons=always --hyperlink=always; }


# --- Backups: see newest first ---
# cya = cover your ass
cya() {
  eza -lah --sort=modified -r ~/backups/
}

# --- /etc/ fuzzy file finder (opens in $EDITOR) ---
# sets fallback to nano instead of vim because wtf
etc() {
  fd -t f "$1" /etc/ | fzf | xargs -r "${EDITOR:-nano}"
}

# --- Services: fuzzy-pick a service, show its status (Linux + macOS) ---
svc() {
  if [[ "$(uname -s)" == "Linux" ]]; then
    systemctl list-units --type=service --no-pager \
    | awk '{print $1}' | fzf | xargs -r systemctl status
  else
    # macOS: launchctl list prints "PID Status Label"; $3 is the label
    launchctl list | awk 'NR>1 {print $3}' | fzf | xargs -r launchctl list
  fi
}

# --- linuxbrew: search installed formulae ---
brewq() {
  brew list | fzf | xargs -r brew info
}

# Show formulae I installed, minus dependencies, optional description
brewl() {
  if [ -n "$1" ]; then
    # Unquoted $(...) on purpose: each name becomes a separate arg to `brew desc`
    brew desc $(cat <(brew leaves --installed-on-request) <(brew list --cask -1) | sort | uniq)
  else
    brew leaves -r
  fi
}

# --- Portable status helpers (Linux + macOS) ---

# Human-readable uptime, e.g. "7 days, 23:45"
_st_uptime() {
  if [[ "$(uname -s)" == "Linux" ]]; then
    uptime -p | sed 's/^up //'
  else
    # macOS `uptime` has no -p flag; grab the "up ..." span before the user count
    uptime | sed -E 's/^.*up (.*), [0-9]+ users?.*$/\1/'
  fi
}

# Load averages "1m 5m 15m" — `uptime` prints these on both OSes
_st_load() {
  uptime | sed -E 's/.*load averages?: //'
}

# Memory as "used / total", roughly matching each OS's own accounting
_st_mem() {
  if [[ "$(uname -s)" == "Linux" ]]; then
    free -h | awk '/Mem/{print $3" / "$2}'
    return
  fi

  # macOS: total from sysctl; used = (active + wired + compressed) pages * pagesize
  local pagesize total_gib used_pages used_gib
  pagesize=$(sysctl -n hw.pagesize)
  total_gib=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
  used_pages=$(vm_stat | awk '
    /^Pages active:/                 { gsub(/\./,"",$3); active=$3 }
    /^Pages wired down:/             { gsub(/\./,"",$4); wired=$4 }
    /^Pages occupied by compressor:/ { gsub(/\./,"",$5); comp=$5 }
    END { print active + wired + comp }')
  used_gib=$(( used_pages * pagesize / 1024 / 1024 / 1024 ))
  printf '%sG / %sG' "${used_gib}" "${total_gib}"
}

# Compact status one-liner: uptime, disk, mem, load
st() {
  echo "── UP:   $(_st_uptime) ──"
  echo "── DISK: $(df -h / | awk 'NR==2{print $4" free ("$5" used)"}') ──"
  echo "── MEM:  $(_st_mem) ──"
  echo "── LOAD: $(_st_load) ──"
}

# Fuzzy interactive ripgrep — type a partial string, arrow through hits
rgs() {
  rg --column --line-number --no-heading --color=always "$1" | \
  fzf --ansi --delimiter : --preview "bat --color=always {1} --highlight-line {2}"
}

rgf() {
  rg --line-number --no-heading --color=always --smart-case "$@" |
    fzf --ansi --delimiter ':' \
        --preview 'bat --color=always --highlight-line {2} {1}' \
        --preview-window '+{2}/2'
}


# Option A: skip preview on narrow terminals, just list 

jview() {
  local cols=$(tput cols)
  if [ "${cols}" -lt 60 ]; then
    fd -t f -e json "$1" | fzf | xargs -r fx
  else
    fd -t f -e json "$1" | \
    fzf --preview 'jq . {} | head -30' \
    | xargs -r fx
  fi
}

# --- Markdown: fzf picks file, preview shows headings, Enter opens treemd ---

mdview() {
  fd -t f -e md "$1" | \
  fzf --preview 'treemd -l {} 2>/dev/null || head -20 {}' \
  | xargs -r treemd
}

