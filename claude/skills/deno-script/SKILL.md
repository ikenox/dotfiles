---
name: deno-script
description: Run ad-hoc local data-processing TypeScript inline via Deno's sandbox instead of writing Python/Perl/Node one-liners OR chaining shell utilities. Use this skill whenever you need a throwaway script to transform files, parse/reshape data, do text/JSON/CSV munging, bulk-rename files, compute statistics, or any other non-trivial local computation that feels too involved for plain shell pipelines. ALSO use this for filesystem inspection / codebase reconnaissance tasks that you'd otherwise express as `find`/`ls`/`wc`/`grep`/`head`/`tail` pipelines — e.g. listing files matching a pattern with extra filtering, counting lines across many files, summarizing directory structure, extracting snippets from many files at once, or any multi-step `find ... | xargs ...` style command. Code is passed as a single argument (no file needed). The sandbox wrapper runs with filesystem-only permissions (no network, no subprocess, no FFI, no env access), so it's pre-approved in settings — users don't get a permission prompt per run. Prefer this over `python -c`, `perl -e`, `node -e`, `ruby -e`, writing throwaway `.py`/`.js` files (those are blocked by a hook anyway), and over multi-stage shell pipelines for inspection. Single-purpose dedicated tools (Read for one known file, Grep for a single regex, a plain `ls` of one directory) are still fine — reach for deno-script when the task involves combining/aggregating across files.
---

# deno-script

Ad-hoc TypeScript runner using Deno's capability-based sandbox. When you need a real programming language for a local task (not just shell), reach for this instead of Python/Node/Perl — it's pre-approved and sandboxed to filesystem-only.

## Why this exists

Writing throwaway Python/Node scripts forces the user to approve each Bash invocation. Deno with inline eval + `--allow-read=$ROOT --allow-write=$ROOT` (where `$ROOT` is the git toplevel) and nothing else gives us:

- No network access (can't exfiltrate)
- No subprocess spawning (can't escape via `Deno.Command`)
- No FFI, no env var reads, no system info
- Reads and writes are both restricted to the current project (git toplevel) subtree
- Must be run inside a git repository — the wrapper resolves the project root via `git rev-parse --show-toplevel` and exits with an error otherwise
- Filesystem is the only side channel, and the user's machine is already trusted to run local code

That's safe enough that the wrapper is pre-approved in `settings.json`.

## How to use

Pass the TypeScript code as a single argument. No file needed.

```bash
~/.claude/skills/deno-script/scripts/run.sh '<typescript code>' [args...]
```

Extra args after the code are available as `Deno.args`.

Use single quotes around the code so bash doesn't expand `$`, backticks, etc. If the code itself contains single quotes, close-escape-reopen (`'\''`) or use a bash heredoc-to-variable first.

### IMPORTANT: keep the entire command on a single line

The pre-approved permission rule is `Bash(~/.claude/skills/deno-script/scripts/run.sh *)`. Claude Code's Bash matcher does **not** match commands that contain literal newlines — if the code argument spans multiple lines, the rule misses and the user gets a permission prompt every time.

Rules to avoid the prompt:

- Write the whole `run.sh '...'` invocation on one physical line. No line breaks inside the quoted code, no backslash continuations.
- Separate TypeScript statements with `;` instead of newlines.
- Need a literal newline in *output* (e.g. inside a generated file)? Use `\n` inside a string — that's fine, the source stays one line.
- If the code is too long to be readable on one line, that's a sign it should be a real `.ts` file run via `deno run` directly (and just accept the one-time permission prompt), not this skill.

## What's available

- Built-in `Deno.*` APIs: `readTextFile`, `writeTextFile`, `readDir`, `stat`, `remove`, etc.
- Top-level `await`.
- Plain TypeScript — no transpile step needed.
- Remote imports (`jsr:`, `https://`) are **not** available since network is disabled. Stick to built-ins. If you genuinely need a remote module, ask the user to `deno cache` it manually first.

## What's NOT available

- `fetch` / network anything
- `Deno.Command` / subprocess
- `Deno.env`
- FFI
- Writes outside the current working directory subtree

If you need one of these, don't try to work around the sandbox — tell the user and ask them to run it manually.

## Examples

All examples are written on a single line — that's mandatory (see above).

**Parse JSON, filter, write CSV:**

```bash
~/.claude/skills/deno-script/scripts/run.sh 'const data = JSON.parse(await Deno.readTextFile("data.json")); const active = data.filter((x: any) => x.status === "active"); const csv = "id,name\n" + active.map((x: any) => `${x.id},${x.name}`).join("\n"); await Deno.writeTextFile("out.csv", csv); console.log(`wrote ${active.length} rows`);'
```

**Bulk-rename files:**

```bash
~/.claude/skills/deno-script/scripts/run.sh 'for await (const entry of Deno.readDir(".")) { if (entry.isFile && entry.name.endsWith(".jpeg")) { await Deno.rename(entry.name, entry.name.replace(/\.jpeg$/, ".jpg")); } }'
```

**Pass runtime args:**

```bash
~/.claude/skills/deno-script/scripts/run.sh 'const [src, dst] = Deno.args; await Deno.copyFile(src, dst);' source.txt dest.txt
```

## When to reach for this

- Non-trivial JSON/CSV/text transformations where `jq`/`awk` gets golfed and unreadable
- Bulk file operations with any conditional logic
- Quick parsing/validation/statistics
- Anything you'd otherwise write as a `python -c` one-liner
- **Filesystem inspection / codebase recon** that would otherwise be a chain of `find` / `ls` / `wc` / `grep` / `head`: listing files by pattern with extra filtering, counting lines across many files, peeking at the first N lines of each match, summarizing a directory tree, etc. Single shell commands (`ls one-dir`, single `grep`) stay in Bash; combinations move here.

**Filesystem inspection example — list `.rs` files under a path with their line counts, sorted:**

```bash
~/.claude/skills/deno-script/scripts/run.sh 'const root = Deno.args[0]; const out: {path: string, lines: number}[] = []; async function walk(d: string) { for await (const e of Deno.readDir(d)) { const p = `${d}/${e.name}`; if (e.isDirectory) await walk(p); else if (e.isFile && e.name.endsWith(".rs")) { const n = (await Deno.readTextFile(p)).split("\n").length; out.push({path: p, lines: n}); } } } await walk(root); out.sort((a, b) => b.lines - a.lines); for (const r of out) console.log(`${r.lines}\t${r.path}`);' packages/exchangeapi/src
```
