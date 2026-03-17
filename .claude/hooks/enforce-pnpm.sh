#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Block npm install/add and yarn add — use pnpm instead
if echo "$COMMAND" | grep -qE '\bnpm (install|i|add)\b|\byarn add\b'; then
  echo "Blocked: use pnpm instead of npm/yarn for installing packages" >&2
  exit 2
fi

exit 0
