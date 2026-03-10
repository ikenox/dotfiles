#!/bin/bash
# Fetch unresolved review threads for a PR using GitHub GraphQL API.
# Usage: fetch_unresolved_threads.sh [PR_NUMBER]
# If PR_NUMBER is omitted, detects from the current branch.

set -euo pipefail

PR_NUMBER="${1:-}"

if [ -z "$PR_NUMBER" ]; then
  PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null) || {
    echo "Error: No PR number provided and no PR found for current branch" >&2
    exit 1
  }
fi

OWNER=$(gh repo view --json owner -q '.owner.login')
REPO=$(gh repo view --json name -q '.name')

gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      url
      title
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          startLine
          subjectType
          comments(first: 100) {
            nodes {
              databaseId
              body
              author {
                login
              }
              createdAt
              url
            }
          }
        }
      }
    }
  }
}' -f owner="$OWNER" -f repo="$REPO" -F pr="$PR_NUMBER" \
  | jq '{
    pr_url: .data.repository.pullRequest.url,
    pr_title: .data.repository.pullRequest.title,
    threads: [
      .data.repository.pullRequest.reviewThreads.nodes[]
      | select(.isResolved == false)
      | {
          id,
          path,
          line,
          startLine,
          subjectType,
          isOutdated,
          comments: [.comments.nodes[] | {
            databaseId,
            body,
            author: .author.login,
            createdAt,
            url
          }]
        }
    ]
  }'
