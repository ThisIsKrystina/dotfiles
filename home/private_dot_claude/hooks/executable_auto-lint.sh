#!/bin/bash
FILE="$CLAUDE_FILE_PATH"

# Check if file is a JS/TS file
if [[ -f "$FILE" && "$FILE" =~ \.(js|jsx|ts|tsx)$ ]]; then
  bun run biome check "$FILE" --format-with-errors 2>/dev/null
fi
