#!/usr/bin/env bash
set -euo pipefail

umask 077

KEY_PATH="${HOME}/.config/chezmoi/key.txt"
OP_URI="op://local/chezmoi-age-key/chezmoi-age-key.txt"

# Skip if key already exists on disk
if [[ -s "${KEY_PATH}" ]]; then
  chmod 600 "${KEY_PATH}"
  exit 0
fi

mkdir -p "$(dirname "${KEY_PATH}")"
op read "${OP_URI}" > "${KEY_PATH}"
chmod 600 "${KEY_PATH}"
