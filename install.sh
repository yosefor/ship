#!/usr/bin/env bash
#
# ship installer.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/yosefor/ship/main/install.sh | bash
#
# Optional: set INSTALL_DIR to override where the `ship` command is placed.
#   curl -fsSL .../install.sh | INSTALL_DIR=/usr/local/bin bash
#
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/yosefor/ship/main/ship"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
TARGET="$INSTALL_DIR/ship"

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
dim()  { printf '\033[2m%s\033[0m\n' "$1"; }
err()  { printf '\033[31m%s\033[0m\n' "$1" >&2; }

command -v git >/dev/null 2>&1 || { err "git is required but not found."; exit 1; }
if ! command -v claude >/dev/null 2>&1 && ! command -v codex >/dev/null 2>&1; then
  dim "Note: neither 'claude' nor 'codex' was found on your PATH."
  dim "ship needs one of them to generate commit messages."
fi

bold "Installing ship to $TARGET"
mkdir -p "$INSTALL_DIR"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$REPO_RAW" -o "$TARGET"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$TARGET" "$REPO_RAW"
else
  err "Need curl or wget to download ship."
  exit 1
fi

chmod +x "$TARGET"
bold "✓ Installed."

# Check that INSTALL_DIR is on PATH.
case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    dim "Run it from any git repo:  ship"
    ;;
  *)
    echo
    err "$INSTALL_DIR is not on your PATH."
    echo "Add this line to your ~/.zshrc (or ~/.bashrc), then restart your shell:"
    echo
    echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac
