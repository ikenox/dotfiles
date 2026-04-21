#!/bin/bash
# Sandbox wrapper for running Deno scripts.
# Grants filesystem read/write only. No network, no subprocess, no FFI, no env.
# Flags are hard-coded here so the permission in settings.json is safe to pre-approve.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <script.ts> [args...]" >&2
  exit 1
fi

SCRIPT="$1"
shift

if [[ "$SCRIPT" == -* ]]; then
  echo "First argument must be a script file, not a flag (got: $SCRIPT)" >&2
  exit 1
fi

if [ ! -f "$SCRIPT" ]; then
  echo "Script not found: $SCRIPT" >&2
  exit 1
fi

exec deno run \
  --allow-read \
  --allow-write \
  --no-prompt \
  "$SCRIPT" \
  "$@"
