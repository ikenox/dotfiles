#!/bin/bash
# Sandbox wrapper for running inline Deno (TypeScript) code.
# Grants filesystem read (unrestricted) and write (cwd subtree only).
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

exec deno run \
  --allow-read \
  --allow-write="$PWD" \
  --no-prompt \
  - \
  "$@" <<<"$CODE"
