#!/bin/bash
CMD=$(jq -r '.tool_input.command')

if echo "$CMD" | grep -qE '\bgit\s+(-[a-zA-Z]+\s+)*-C\b'; then
  echo "Do not use git -C option. Use cd instead." >&2
  exit 2
fi

exit 0
