#!/bin/bash
set -euo pipefail

input=$(cat)

# Extract file path based on tool type
tool_name=$(echo "$input" | jq -r '.tool_name // empty')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only check .ts and .tsx files
case "$file_path" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Skip declaration, test, and spec files
case "$file_path" in
  *.d.ts|*.test.ts|*.spec.ts|*.test.tsx|*.spec.tsx) exit 0 ;;
esac

# Get the content being written
if [ "$tool_name" = "Write" ]; then
  content=$(echo "$input" | jq -r '.tool_input.content // empty')
elif [ "$tool_name" = "Edit" ]; then
  content=$(echo "$input" | jq -r '.tool_input.new_string // empty')
else
  exit 0
fi

# Check if content has exports without JSDoc
has_undocumented=false
while IFS= read -r line; do
  if echo "$line" | grep -qE '^[[:space:]]*export[[:space:]]+(default[[:space:]]+)?(async[[:space:]]+)?(function|const|class|interface|type|enum)[[:space:]]+'; then
    has_undocumented=true
    break
  fi
done < <(echo "$content" | awk '
  /\/\*\*/ { in_jsdoc=1 }
  /\*\//   { if(in_jsdoc) { in_jsdoc=0; documented=1; next } }
  /^[[:space:]]*export[[:space:]]+(default[[:space:]]+)?(async[[:space:]]+)?(function|const|class|interface|type|enum)[[:space:]]+/ {
    if(!documented) print
    documented=0
  }
  { if(!in_jsdoc) documented=0 }
')

if [ "$has_undocumented" = "true" ]; then
  echo '{"systemMessage":"JSDoc reminder: this file contains exported constructs without JSDoc documentation. Consider adding /** */ comments before each export. Consult the jsdoc-conventions skill for the appropriate documentation level."}'
fi

exit 0
