#!/usr/bin/env bash
set -euo pipefail

KEY_PATH="${HOME}/.config/chezmoi/key.txt"

if [[ -f "${KEY_PATH}" ]]; then
  shred -u "${KEY_PATH}" 2>/dev/null || rm -f "${KEY_PATH}"
fi   
