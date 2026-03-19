#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command' || true)

# Split chained commands (&&, ||, ;) into separate lines and check if any
# starts with npm/yarn. This avoids false positives when "npm" appears
# inside arguments (e.g., git commit messages).
if echo "$COMMAND" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g' | grep -qE '^\s*npm\s+(install|i|add)\b|^\s*yarn\s+add\b'; then
  echo "Blocked: use pnpm instead of npm/yarn for installing packages" >&2
  exit 2
fi

exit 0
