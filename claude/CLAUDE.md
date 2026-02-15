## Workflow

**IMPORTANT: Before making ANY file changes, you MUST complete step 1. No exceptions, even for small or single-file changes.**

1. Create a branch and worktree: fetch the latest remote default branch (`git fetch origin $DEFAULT_BRANCH`), then create a new branch from `origin/$DEFAULT_BRANCH` and a git worktree for it under `.worktree/`, and `cd` into it so that all subsequent commands run inside the worktree. Choose an appropriate branch/worktree name based on the task description. Do not commit directly to main. Unless the user explicitly instructs otherwise (e.g., working on an existing branch, or skipping worktree creation), always follow this step.
2. Make your changes in the worktree.

## Git

- Do not use the `-C` option with git commands. Always `cd` into the target directory instead.
- When writing commit messages, pull request descriptions, and code comments, match the natural language used in the repository (e.g., English or Japanese). Determine the appropriate language by checking the existing commit log.