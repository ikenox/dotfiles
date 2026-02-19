## Workflow

**IMPORTANT: Before making ANY file changes, you MUST complete step 1. No exceptions, even for small or single-file changes.**

1. If the current branch is the default branch (e.g., main or master), create a branch and worktree: fetch the latest remote default branch (`git fetch origin $DEFAULT_BRANCH`), then create a new branch from `origin/$DEFAULT_BRANCH` and a git worktree for it under `.worktree/`, and `cd` into it so that all subsequent commands run inside the worktree. Choose an appropriate branch/worktree name based on the task description. Do not commit directly to the default branch. Unless the user explicitly instructs otherwise (e.g., skipping worktree creation), always follow this step. If already on a non-default branch, skip worktree creation and work directly on the current branch.
2. Make your changes.

## Git

- Do not use the `-C` option with git commands. Always `cd` into the target directory instead.
- **IMPORTANT: When writing commit messages, pull request descriptions, and code comments, you MUST match the natural language used in the repository. Before writing any commit message or PR description, ALWAYS run `git log --oneline -10` first to check the language (e.g., English or Japanese) used in recent commits, and write in that same language. This is a strict requirement — do NOT default to English without checking.**