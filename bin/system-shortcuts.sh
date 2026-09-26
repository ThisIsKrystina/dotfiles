# Type "where" to see where you are + what's here, in one shot
where() { echo "\n$(pwd)\n"; eza -la --git --group-directories-first --icons=always --hyperlink=always; }

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

# --- systemd: fuzzy-pick a service, show status ---
svc() {
  systemctl list-units --type=service --no-pager \
  | awk '{print $1}' | fzf | xargs -r systemctl status
}

# --- linuxbrew: search installed formulae ---
brewq() {
  brew list | fzf | xargs -r brew info
}

# Show formulae I installed, minus dependencies, optional description
brewl() {
  
  if [ -n "$1" ]; then
    brew desc $(cat <(brew leaves --installed-on-request) <(brew list --cask -1) | sort | uniq)
  else
    brew leaves -r
  fi
  
}

# Compact status one-liner: uptime, disk, mem
st() {
  echo "── UP: $(uptime -p | sed 's/up //') ──"
  echo "── DISK: $(df -h / | awk 'NR==2{print $4" free ("$5" used)"}') ──"
  echo "── MEM: $(free -h | awk '/Mem/{print $3" / "$2"}') ──"
  echo "── LOAD: $(cat /proc/loadavg | awk '{print $1,$2,$3}') ──"
}

# Fuzzy interactive ripgrep — type a partial string, arrow through hits
rgs() {
  rg --column --line-number --no-heading --color=always "$1" | \
  fzf --ansi --delimiter : --preview "bat --color=always {1} --highlight-line {2}"
}

# Option A: skip preview on narrow terminals, just list
jview() {
  local cols=$(tput cols)
  if [ "$cols" -lt 60 ]; then
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

