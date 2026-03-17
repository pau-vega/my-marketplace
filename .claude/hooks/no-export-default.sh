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

if echo "$CONTENT" | grep -q 'export default'; then
  echo "Blocked: do not use 'export default' — use named exports instead" >&2
  exit 2
fi

exit 0
