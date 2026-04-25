#!/bin/bash
# Sandbox wrapper for running inline Deno (TypeScript) code.
# Grants filesystem read/write restricted to the current project (git toplevel).
# No network, no subprocess, no FFI, no env. Flags are hard-coded so the
# permission in settings.json is safe to pre-approve.
#
# Note: `deno eval` does not accept permission flags, so we pipe the code
# through stdin into `deno run -` instead. This means the script cannot
# read from stdin itself — an acceptable trade-off for ad-hoc use.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") '<typescript code>' [args...]" >&2
  exit 1
fi

CODE="$1"
shift

if ! ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "deno-script: must be run inside a git repository (project root is resolved via git)." >&2
  exit 1
fi

exec deno run \
  --allow-read="$ROOT" \
  --allow-write="$ROOT" \
  --no-prompt \
  - \
  "$@" <<<"$CODE"
