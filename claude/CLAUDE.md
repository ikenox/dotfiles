## Git

- **IMPORTANT — Natural language rule for git output (commit messages, PR titles, PR descriptions, code comments):**
  1. Before writing ANY commit message or PR description, ALWAYS run `git log --oneline -10` first.
  2. Determine the language used in those commit messages (e.g., English or Japanese).
  3. Write your commit message, PR title, PR description, and code comments in **that same language**.
  4. **The language of the user's conversation prompt is IRRELEVANT. Even if the user writes in Japanese, if the git log is in English, you MUST write in English. Even if the user writes in English, if the git log is in Japanese, you MUST write in Japanese. The ONLY source of truth is the git log.**
  5. Double-check before finalizing: re-read your draft and confirm it matches the git log language. If it doesn't, rewrite it.
- Do not use the `-C` option with git commands. Always `cd` into the target directory instead.

## Temporary files

- Claude が作業中に作成する一時ファイルは `.claude/tmp/` 以下に置くこと。プロジェクトルート直下や `/tmp` に散らかさない。