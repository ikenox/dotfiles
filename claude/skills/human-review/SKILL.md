---
name: human-review
description: Request a code review from the developer and apply fixes based on review comments.
---

1. Run `git add -N . && git diff | pnpx difit` to open the diff in a browser-based review UI. `git add -N .` ensures untracked new files are included in the diff. The reviewer will read the diff and leave comments on specific lines. When the reviewer closes the UI, the review comments (with file paths, line numbers, and comment text) are printed to stdout.
2. Read the review output carefully. For each comment, understand the requested change and apply the fix to the corresponding file and line.
3. After applying all fixes, run `git add -N . && git diff | pnpx difit` again so the reviewer can verify the changes. Repeat until the reviewer closes the UI with no comments.
