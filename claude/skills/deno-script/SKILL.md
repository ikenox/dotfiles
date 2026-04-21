---
name: deno-script
description: Run ad-hoc local data-processing TypeScript inline via Deno's sandbox instead of writing Python/Perl/Node one-liners. Use this skill whenever you need a throwaway script to transform files, parse/reshape data, do text/JSON/CSV munging, bulk-rename files, compute statistics, or any other non-trivial local computation that feels too involved for plain shell pipelines. Code is passed as a single argument (no file needed). The sandbox wrapper runs with filesystem-only permissions (no network, no subprocess, no FFI, no env access), so it's pre-approved in settings — users don't get a permission prompt per run. Prefer this over `python -c`, `perl -e`, `node -e`, `ruby -e`, or writing throwaway `.py`/`.js` files (those are blocked by a hook anyway).
---

# deno-script

Ad-hoc TypeScript runner using Deno's capability-based sandbox. When you need a real programming language for a local task (not just shell), reach for this instead of Python/Node/Perl — it's pre-approved and sandboxed to filesystem-only.

## Why this exists

Writing throwaway Python/Node scripts forces the user to approve each Bash invocation. Deno with inline eval + `--allow-read --allow-write=$PWD` and nothing else gives us:

- No network access (can't exfiltrate)
- No subprocess spawning (can't escape via `Deno.Command`)
- No FFI, no env var reads, no system info
- Writes are restricted to the cwd subtree; reads are unrestricted
- Filesystem is the only side channel, and the user's machine is already trusted to run local code

That's safe enough that the wrapper is pre-approved in `settings.json`.

## How to use

Pass the TypeScript code as a single argument. No file needed.

```bash
~/.claude/skills/deno-script/scripts/run.sh '<typescript code>' [args...]
```

Extra args after the code are available as `Deno.args`.

Use single quotes around the code so bash doesn't expand `$`, backticks, etc. If the code itself contains single quotes, close-escape-reopen (`'\''`) or use a bash heredoc-to-variable first.

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

**Parse JSON, filter, write CSV:**

```bash
~/.claude/skills/deno-script/scripts/run.sh '
  const data = JSON.parse(await Deno.readTextFile("data.json"));
  const active = data.filter((x: any) => x.status === "active");
  const csv = "id,name\n" + active.map((x: any) => `${x.id},${x.name}`).join("\n");
  await Deno.writeTextFile("out.csv", csv);
  console.log(`wrote ${active.length} rows`);
'
```

**Bulk-rename files:**

```bash
~/.claude/skills/deno-script/scripts/run.sh '
  for await (const entry of Deno.readDir(".")) {
    if (entry.isFile && entry.name.endsWith(".jpeg")) {
      await Deno.rename(entry.name, entry.name.replace(/\.jpeg$/, ".jpg"));
    }
  }
'
```

**Pass runtime args:**

```bash
~/.claude/skills/deno-script/scripts/run.sh '
  const [src, dst] = Deno.args;
  await Deno.copyFile(src, dst);
' source.txt dest.txt
```

## When to reach for this

- Non-trivial JSON/CSV/text transformations where `jq`/`awk` gets golfed and unreadable
- Bulk file operations with any conditional logic
- Quick parsing/validation/statistics
- Anything you'd otherwise write as a `python -c` one-liner
