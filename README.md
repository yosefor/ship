# ship

Smart `git push`: stage your changes, let AI write the commit message from the diff, commit, and push to the current branch — in one command.

```console
$ ship
Generating commit message with codex…

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
3. Stages everything (`git add -A`) and asks the selected commit model to write a [Conventional Commits](https://www.conventionalcommits.org/) message from the diff. The default is [`codex`](https://developers.openai.com/codex/cli/) using `gpt-5.6-terra`; you can switch to [`claude`](https://claude.com/claude-code).
4. Commits, then pushes to the current branch (sets the upstream automatically on the first push).
5. Prints the commit message and the branch.

The generated message never mentions AI, Claude, Codex, or any tooling — it just describes your change.

## Commit model

`ship` uses Codex for commit messages by default. To switch to Claude:

```bash
ship config commit-model claude
```

To switch back to Codex:

```bash
ship config commit-model codex
```

You can also override the commit model for one run:

```bash
ship --commit-model codex
ship --commit-model claude
```

For scripts, `SHIP_COMMIT_MODEL=claude ship` works too. Supported values are `claude` and `codex`.

### Codex model

Codex runs default to `gpt-5.6-terra`. Set a different model persistently:

```bash
ship config model gpt-5.6-terra
```

Or choose one for a single run:

```bash
ship --model gpt-5.6-terra
```

`SHIP_MODEL` provides the same one-run override for scripts.

## Review before you ship

Add `--review` (or `-r`) to have Codex thoroughly review the staged diff **before** anything is committed or pushed. Reviews use `gpt-5.6-terra` at **high** reasoning effort by default and are asked to find every real production issue they can identify, not just the first one.

```console
$ ship --review
Reviewing changes…

✗ Review requested changes — not pushing yet.

- config.js: Remove the hard-coded AWS_SECRET_KEY on line 12 — never commit secrets.
- api.js: console.log(password) on line 40 is a debugging leftover; remove it.

Choose how to continue:
› Push anyway
  Fix once with codex, then review again
  Fix and review until approved with codex

Use ↑/↓ and Enter, or click an option in a compatible terminal.
```

When a review requests changes, `ship -r` presents an arrow-key menu (with click support in compatible terminals). You can deliberately push anyway, fix once with your configured default commit model (`codex` or `claude`) and review again, or keep fixing and reviewing until Codex approves the diff. The fixes are staged before every repeat review. If an automatic fixer makes no staged changes, the menu returns so it cannot loop forever. In a non-interactive shell, it keeps the safe behavior: it stops with the changes staged.

When the review passes, `ship --review` continues straight into the normal commit-and-push flow.

The review flags real problems — bugs, security issues, leaked secrets, debugging leftovers, and broken code — and won't block on style nitpicks or missing tests alone. `ship review` and non-interactive `ship -r` default to *not* pushing: anything other than a clear pass stops the flow, and the exit code is non-zero so CI and scripts can detect it.

Use `ship review` (the bare command) to **review only** — it runs the review and stops regardless of the verdict, never committing or pushing.

Set the default review reasoning effort, or override it for one run:

```bash
ship config review-thinking-effort high
ship --review-thinking-effort medium --review
```

Allowed efforts are `minimal`, `low`, `medium`, `high`, and `xhigh`. `SHIP_REVIEW_THINKING_EFFORT` is available for scripts. Use `--model` (or `SHIP_MODEL`) to choose the Codex model used for both review and commit generation.

## Requirements

- **git**
- **[Claude Code](https://claude.com/claude-code)** or **[Codex CLI](https://developers.openai.com/codex/cli/)** — install the CLI for whichever commit model you use.

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
ship exit         Run the smart-push flow, then close this editor window
ship -r           Review the diff first; on findings choose push, fix once, or
                  auto-fix and re-review until it passes
ship review       Review only — never commit or push
ship -n           Dry run: generate + show the message, but don't commit/push
ship --exit-editor
                  Close this Cursor or VS Code window after a successful push
ship --commit-model codex
                  Use Codex for this run's commit message
ship config commit-model codex
                  Use Codex by default for commit messages
ship --model gpt-5.6-terra
                  Use this Codex model for this run
ship config model gpt-5.6-terra
                  Use this Codex model by default
ship --review-thinking-effort high --review
                  Set Codex review reasoning effort for this run
ship config review-thinking-effort high
                  Set Codex review reasoning effort by default
ship --help       Show help
```

## Notes

- `ship` stages **everything** (`git add -A`) before committing.
- The first push to a new branch runs `git push -u origin <branch>` to set the upstream; later pushes use plain `git push`.
- `ship exit` and `ship --exit-editor` close only the current Cursor or VS Code window after `git push` succeeds. If both are open and `ship` cannot tell which terminal launched it, set `SHIP_EXIT_EDITOR_APP=Cursor` or `SHIP_EXIT_EDITOR_APP='Visual Studio Code'`.
- Very large diffs (>60k chars) are truncated before being sent to the model; a `--stat` summary is always included so the message still reflects the whole change.

## License

[MIT](LICENSE)
