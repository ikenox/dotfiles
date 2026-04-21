#!/bin/bash
# Block ad-hoc Python/Perl/Node/Ruby script execution.
# Rationale: each invocation triggers a permission prompt and bypasses the
# deno sandbox wrapper. Steer Claude toward the deno-script skill instead.
#
# Blocks:
#   - inline eval flags: `python -c`, `perl -e`, `node -e`, `ruby -e`, `bun -e`
#   - direct interpreter-file invocation: `python foo.py`, `perl foo.pl`,
#     `ruby foo.rb`, `node foo.js` / `.mjs` / `.cjs` / `.ts`
#
# Does NOT block: npm, npx, pytest, bun run, bun install, package managers, etc.

CMD=$(jq -r '.tool_input.command')

MSG='Ad-hoc Python/Perl/Node/Ruby scripting is disabled. Use the deno-script skill instead: ~/.claude/skills/deno-script/scripts/run.sh <script.ts>'

# Inline eval (-e / -c)
if echo "$CMD" | grep -qE '(^|[[:space:];|&])(python3?|perl|node|ruby|bun)([[:space:]]+-[a-zA-Z]*)*[[:space:]]+-(e|c)([[:space:]]|$)'; then
  echo "$MSG" >&2
  exit 2
fi

# Direct script-file execution
if echo "$CMD" | grep -qE '(^|[[:space:];|&])(python3?|perl|ruby)[[:space:]]+[^-[:space:]][^[:space:]]*\.(py|pl|rb)([[:space:]]|$)'; then
  echo "$MSG" >&2
  exit 2
fi

if echo "$CMD" | grep -qE '(^|[[:space:];|&])node[[:space:]]+[^-[:space:]][^[:space:]]*\.(js|mjs|cjs|ts)([[:space:]]|$)'; then
  echo "$MSG" >&2
  exit 2
fi

exit 0
