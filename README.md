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
ship -n           Dry run: generate + show the message, but don't commit/push
ship --help       Show help
```

## Notes

- `ship` stages **everything** (`git add -A`) before committing.
- The first push to a new branch runs `git push -u origin <branch>` to set the upstream; later pushes use plain `git push`.
- Very large diffs (>60k chars) are truncated before being sent to the model; a `--stat` summary is always included so the message still reflects the whole change.

## License

[MIT](LICENSE)
