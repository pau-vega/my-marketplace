#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

# Only check .ts/.tsx files
if ! echo "$FILE_PATH" | grep -qE '\.(ts|tsx)$'; then
  exit 0
fi

# Get content based on tool type
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
if [ "$TOOL" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content')
else
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string')
fi

# Match ': any', 'as any', and '<any>' patterns (not words like "company", "many")
if echo "$CONTENT" | grep -qE ':\s*any([^a-zA-Z0-9_]|$)|as any([^a-zA-Z0-9_]|$)|<any>|<any,'; then
  echo "Blocked: do not use 'any' — use generics, 'unknown', or function overloads instead" >&2
  exit 2
fi

exit 0
