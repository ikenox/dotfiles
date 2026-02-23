## Workflow

**IMPORTANT: Before making ANY file changes, you MUST complete step 1. No exceptions, even for small or single-file changes.**

1. If the current branch is the default branch (e.g., main or master), create a branch and worktree: fetch the latest remote default branch (`git fetch origin $DEFAULT_BRANCH`), then create a new branch from `origin/$DEFAULT_BRANCH` and a git worktree for it under `.worktree/`, and `cd` into it so that all subsequent commands run inside the worktree. Choose an appropriate branch/worktree name based on the task description. Do not commit directly to the default branch. Unless the user explicitly instructs otherwise (e.g., skipping worktree creation), always follow this step. If already on a non-default branch, skip worktree creation and work directly on the current branch.
2. Make your changes.

## Git

- **IMPORTANT — Natural language rule for git output (commit messages, PR titles, PR descriptions, code comments):**
  1. Before writing ANY commit message or PR description, ALWAYS run `git log --oneline -10` first.
  2. Determine the language used in those commit messages (e.g., English or Japanese).
  3. Write your commit message, PR title, PR description, and code comments in **that same language**.
  4. **The language of the user's conversation prompt is IRRELEVANT. Even if the user writes in Japanese, if the git log is in English, you MUST write in English. Even if the user writes in English, if the git log is in Japanese, you MUST write in Japanese. The ONLY source of truth is the git log.**
  5. Double-check before finalizing: re-read your draft and confirm it matches the git log language. If it doesn't, rewrite it.
- Do not use the `-C` option with git commands. Always `cd` into the target directory instead.