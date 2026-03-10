#!/bin/bash
# Reply to a PR review comment thread.
# Usage: reply_to_thread.sh <PR_NUMBER> <COMMENT_DATABASE_ID> <REPLY_BODY>
# COMMENT_DATABASE_ID is the databaseId of any comment in the thread.

set -euo pipefail

PR_NUMBER="${1:?Usage: reply_to_thread.sh <PR_NUMBER> <COMMENT_DATABASE_ID> <REPLY_BODY>}"
COMMENT_ID="${2:?Usage: reply_to_thread.sh <PR_NUMBER> <COMMENT_DATABASE_ID> <REPLY_BODY>}"
BODY="${3:?Usage: reply_to_thread.sh <PR_NUMBER> <COMMENT_DATABASE_ID> <REPLY_BODY>}"

gh api "repos/{owner}/{repo}/pulls/${PR_NUMBER}/comments/${COMMENT_ID}/replies" \
  -f body="$BODY"
