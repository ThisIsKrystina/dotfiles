#!/bin/bash
# Opens new tab and edits kitty config via chezmoi so it updates
CONFIG_PATH="~/.config/kitty/kitty-conf.conf"
kitten @ launch --type=tab --location=right "chezmoi edit --apply ${CONFIG_PATH}"
kitten @ focus-window
