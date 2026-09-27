#!/usr/bin/env bash
# @description: attaches a tmux session if remote while running ssh in kitty
HOST="$1"
[ -z "$HOST" ] && { echo "usage: kitty-remote <host>"; exit 1; }

kitty +kitten ssh "$HOST" "tmux new-session -A -s $HOST"   
