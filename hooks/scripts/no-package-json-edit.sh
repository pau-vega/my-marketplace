#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

if echo "$FILE_PATH" | grep -q 'package\.json$'; then
  echo "Blocked: do not manually edit package.json — use 'pnpm add' or 'pnpm remove' instead" >&2
  exit 2
fi

exit 0
