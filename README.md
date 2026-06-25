# ship

Smart `git push`: stage your changes, let AI write the commit message from the diff, commit, and push to the current branch — in one command.

```console
$ ship
Generating commit message…

Commit message:
feat: add sub() function for subtraction

- add sub(a, b) returning the difference of two operands

Pushing to 'main'…
   3432703..993a0b7  main -> main

✓ Pushed to branch: main
```

## What it does

1. Confirms you're inside a git repo.
2. Checks for changes (staged, unstaged, or untracked) — no-ops if the tree is clean.
3. Stages everything (`git add -A`) and asks the [`claude`](https://claude.com/claude-code) CLI to write a [Conventional Commits](https://www.conventionalcommits.org/) message from the diff.
4. Commits, then pushes to the current branch (sets the upstream automatically on the first push).
5. Prints the commit message and the branch.

The generated message never mentions AI, Claude, or any tooling — it just describes your change.

## Review before you ship

Add `--review` (or `-r`) to have the `claude` CLI review the staged diff **before** anything is committed or pushed. It only pushes if the review passes; otherwise it prints what to change and stops — your changes stay staged.

```console
$ ship --review
Reviewing changes…

✗ Review requested changes — not pushing.

- config.js: Remove the hard-coded AWS_SECRET_KEY on line 12 — never commit secrets.
- api.js: console.log(password) on line 40 is a debugging leftover; remove it.

Your changes are staged. Address the above, then run 'ship' again.
```

When the review passes, `ship --review` continues straight into the normal commit-and-push flow.

The review flags real problems — bugs, security issues, leaked secrets, debugging leftovers, and broken code — and won't block on style nitpicks or missing tests alone. It defaults to *not* pushing: anything other than a clear pass stops the flow, and the exit code is non-zero so CI and scripts can detect it.

Use `ship review` (the bare command) to **review only** — it runs the review and stops regardless of the verdict, never committing or pushing.

## Requirements

- **git**
- **[Claude Code](https://claude.com/claude-code)** — the `claude` CLI must be installed and on your `PATH` (used to generate the message).

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/yosefor/ship/main/install.sh | bash
```

This drops the `ship` command into `~/.local/bin`. If that directory isn't on your `PATH`, the installer tells you the line to add to your shell config.

To install somewhere else (e.g. a system-wide bin):

```bash
curl -fsSL https://raw.githubusercontent.com/yosefor/ship/main/install.sh | INSTALL_DIR=/usr/local/bin bash
```

### Manual install

```bash
git clone https://github.com/yosefor/ship.git
cd ship
chmod +x ship
ln -s "$PWD/ship" ~/.local/bin/ship   # or any dir on your PATH
```

## Usage

```
ship              Run the smart-push flow
ship push         Same thing (reads naturally)
ship -r           Review the diff first; only push if it passes (--review)
ship review       Review only — never commit or push
ship -n           Dry run: generate + show the message, but don't commit/push
ship --help       Show help
```

## Notes

- `ship` stages **everything** (`git add -A`) before committing.
- The first push to a new branch runs `git push -u origin <branch>` to set the upstream; later pushes use plain `git push`.
- Very large diffs (>60k chars) are truncated before being sent to the model; a `--stat` summary is always included so the message still reflects the whole change.

## License

[MIT](LICENSE)
