#!/bin/bash
# ===== Saves snippets from terminals in Snippety

# Usage: snip "function_name" "keyword" [--param p1 --param p2] ["description"]
snip() {
  local func="$1" keyword="$2"
  shift 2

  local params=() desc="" tags=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --param) params+=("$2"); shift 2 ;;
      --tag)   tags="$2"; shift 2 ;;
      *)       desc="$1"; shift ;;
    esac
  done

  # Build template: function name + placeholder params
  local template="$func"
  for p in "${params[@]}"; do
    template+=" --${p} <${p}>"
  done

  # Build description if not provided
  if [[ -z "$desc" ]]; then
    if [[ ${#params[@]} -gt 0 ]]; then
      desc="Params: ${params[*]}"
    else
      desc="No required params"
    fi
  fi

  local cmd=(snippety add "$func" --keyword "$keyword" --template "$template" --description "$desc")
  [[ -n "$tags" ]] && cmd+=(--tag "$tags")

  "${cmd[@]}"
  echo "✓ Saved: $func → keyword '$keyword'"
   # Update the params JSON
   # Alfred uses in script filter s
  local map_file="$HOME/.snip_params.json"
  [[ -f "$map_file" ]] || echo '{}' > "$map_file"
  local params_json
  params_json=$(printf '%s\n' "${params[@]}" | jq -R . | jq -s .)
  jq --arg f "$func" --argjson p "$params_json" '.[$f] = $p' "$map_file" > "$map_file.tmp" \
    && mv "$map_file.tmp" "$map_file"
}

# Saves last command as snippet 

snip-last() {
  local prev
  prev=$(history 1 | sed 's/^ *[0-9]* *//')
  local func="${prev%% *}"
  local flags
  flags=$(echo "$prev" | grep -oE '\s--[a-z-]+' | tr -d ' ')
  local params
  params=$(echo "$flags" | sed 's/--//g' | tr '\n' ' ')

  snip "$func" "$func" $flags "Auto-captured"
}

# ======= SAVE PARAMS FOR AUTOCOMPLETIONS

_snip_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"
  local map_file="$HOME/.snip_params.json"

  if [[ $COMP_CWORD -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "$(declare -F | awk '{print $3}')" -- "$cur") )
    return
  fi

  if [[ "$prev" == "--param" ]]; then
    local func="${COMP_WORDS[1]}"
    local params
    params=$(jq -r --arg f "$func" '.[$f][] // empty' "$map_file" 2>/dev/null)
    COMPREPLY=( $(compgen -W "$params" -- "$cur") )
    return
  fi

  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "--param --tag --description" -- "$cur") )
  fi
}
complete -F _snip_completions snip


