---
name: deno-script
description: Run ad-hoc local data-processing scripts via Deno's sandbox instead of writing Python/Perl/Node one-liners. Use this skill whenever you need a throwaway script to transform files, parse/reshape data, do text/JSON/CSV munging, bulk-rename files, compute statistics, or any other non-trivial local computation that feels too involved for plain shell pipelines. The sandbox wrapper runs scripts with filesystem-only permissions (no network, no subprocess, no FFI, no env access), so it's pre-approved in settings — users don't get a permission prompt per run. Prefer this over `python -c`, `perl -e`, `node -e`, `ruby -e`, or writing throwaway `.py`/`.js` files (those are blocked by a hook anyway).
---

# deno-script

Ad-hoc scripting runner using Deno's capability-based sandbox. The goal: when you need a real programming language for a task (not just shell), reach for this instead of Python/Node/Perl — it's pre-approved and automatically sandboxed to filesystem-only.

## Why this exists

Writing throwaway Python/Node scripts forces the user to approve each Bash invocation. Deno with `--allow-read --allow-write` and nothing else gives us:

- No network access (can't exfiltrate)
- No subprocess spawning (can't escape via `Deno.Command`)
- No FFI, no env var reads, no system info
- Writes are restricted to the cwd subtree (`--allow-write=$PWD`); reads are unrestricted
- Filesystem is the only side channel, and the user's machine is already trusted to run local code

That's safe enough that the wrapper is pre-approved in `settings.json`, so no permission prompt.

## How to use

1. Write a TypeScript file somewhere under `.claude/tmp/` (per user's temp-file rule). Use `.ts` extension.
2. Run it via the wrapper:

```bash
~/.claude/skills/deno-script/scripts/run.sh .claude/tmp/my-script.ts [args...]
```

The wrapper enforces the sandbox — you cannot override its flags. Anything after the script path is passed through as script args (`Deno.args`).

## What's available inside the script

- Built-in `Deno.*` APIs: `readTextFile`, `writeTextFile`, `readDir`, `stat`, `remove`, etc.
- Plain TypeScript — no transpile step needed.
- Remote imports (`jsr:`, `https://`) are **not** available since network is disabled. Stick to built-ins. If you genuinely need a remote module, ask the user to run `deno cache <script>` manually first.

## What's NOT available

- `fetch` / network anything
- `Deno.Command` / subprocess
- `Deno.env`
- FFI

If you actually need one of these, don't try to work around the sandbox — tell the user and ask them to run it manually or add a narrower permission.

## Example

Task: parse `data.json`, filter entries where `status === "active"`, write to `out.csv`.

```typescript
// .claude/tmp/filter-active.ts
const data = JSON.parse(await Deno.readTextFile("data.json"));
const active = data.filter((x: { status: string }) => x.status === "active");
const header = "id,name,status\n";
const rows = active.map((x: { id: number; name: string; status: string }) =>
  `${x.id},${x.name},${x.status}`
).join("\n");
await Deno.writeTextFile("out.csv", header + rows);
console.log(`wrote ${active.length} rows`);
```

Run:
```bash
~/.claude/skills/deno-script/scripts/run.sh .claude/tmp/filter-active.ts
```

## Notes

- Keep scripts under `.claude/tmp/` so they don't clutter the repo.
- Prefer this over `jq` when the logic gets non-trivial (nested conditionals, multi-pass, joins) — readable TS beats golfed `jq`.
- Use it even for one-off tasks; speed of writing a TS file is comparable to writing a Python one-liner and the user won't be prompted.
