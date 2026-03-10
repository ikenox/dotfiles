---
name: address-reviews
description: |
  Address unresolved PR review comments: fetch all unresolved threads, propose response plans, get developer approval, implement changes with per-comment commits, and reply to each thread. Use this skill whenever the user wants to address, respond to, handle, or fix PR review comments, review feedback, or code review suggestions. Also trigger for phrases like "レビュー対応", "レビューコメント対応", "指摘対応", "レビュー指摘", or any mention of dealing with reviewer feedback on a pull request.
---

# Address PR Review Comments

Handle the full workflow of responding to unresolved PR review comments: understand the feedback, plan responses, get developer approval, implement changes, and notify reviewers.

## Workflow

### 1. Identify the PR

If the user provides a PR number or URL, use that. Otherwise, detect from the current branch:

```bash
gh pr view --json number,url,title
```

If no PR is found, ask the user which PR to work on.

### 2. Fetch unresolved review threads

Run the bundled script (`scripts/fetch_unresolved_threads.sh` next to this file):

```bash
bash <path-to-scripts>/fetch_unresolved_threads.sh [PR_NUMBER]
```

The script returns JSON with each thread's file path, line number, all comments, and metadata. If there are no unresolved threads, let the user know and stop.

### 3. Read the code and understand context

For each unresolved thread:
- Read the file at the path and line mentioned
- Read the **full conversation** in the thread — later comments often clarify or refine the original feedback
- Note whether the thread is marked as outdated (the code may have changed since the comment was made, but the feedback might still be relevant)

### 4. Propose response plans

Present a plan covering ALL unresolved comments at once. For each thread, propose one of:

- **Code change** — describe what will change and why it addresses the feedback
- **Explanation/Counter-argument** — when the current code is intentionally written this way, draft a reply explaining the reasoning

Format the plan so the developer can review everything at a glance:

```
## Review Comment Responses

### 1. path/to/file.ts:42 — @reviewer: "summary of their comment"
**Action**: Code change
**Plan**: Change X to Y because Z

### 2. path/to/file.ts:88 — @reviewer: "summary of their comment"
**Action**: Explanation
**Draft reply**: The current approach is intentional because...
```

### 5. Get developer approval

Present the plan and wait for the developer to approve, modify, or add context. Do not proceed until they confirm.

### 6. Execute changes

For each approved code change:
1. Make the code change
2. Commit with a message that describes the change
   - Check `git log --oneline -10` to match the repo's commit message language and style
   - Each review comment gets its own commit

After all commits are created, push once:

```bash
git push
```

### 7. Reply to reviewers

After pushing, reply to each review thread using the bundled script (`scripts/reply_to_thread.sh` next to this file):

```bash
bash <path-to-scripts>/reply_to_thread.sh <PR_NUMBER> <COMMENT_DATABASE_ID> <REPLY_BODY>
```

The `COMMENT_DATABASE_ID` is the `databaseId` of any comment in the thread (available from the fetch output in step 2).

Guidelines for replies:
- For code changes: mention the commit hash and briefly describe what was changed
- For explanations: post the approved explanation text
- Reply in the same language the reviewer used in their comment
- Do NOT resolve the conversation — leave that to the reviewer

## Notes

- When multiple comments touch the same area of code, read all of them before making changes to avoid conflicts between per-comment commits
- The developer's approval is the critical gate — never skip it, even for seemingly obvious fixes
