#!/usr/bin/env bash
#
# install.sh - copy this toolkit's drop-in pieces into a target project's .claude/.
#
# Usage:
#   ./install.sh <target-project-dir> [--dry-run] [--force]
#
# Copies the portable, ready-to-use pieces (skills, agents, hooks,
# shared, prompting.md, statusline.sh) into <target>/.claude/, and drops
# settings.example.json alongside for you to wire by hand. docs/ (and the root
# CLAUDE.md/AGENTS.md) are reference material and are NOT installed.
#
# Existing files are kept (skipped) by default. Pass --force to overwrite.
# Pass --dry-run to preview without writing anything.

set -euo pipefail

# The toolkit root is the directory this script lives in.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
FORCE=0
TARGET=""

# --- Argument parsing ---
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    -h|--help)
      grep '^#' "$0" | grep -v '^#!' | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)  echo "unknown option: $arg" >&2; exit 2 ;;
    *)
      if [ -z "$TARGET" ]; then TARGET="$arg"
      else echo "unexpected argument: $arg" >&2; exit 2; fi ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "usage: $0 <target-project-dir> [--dry-run] [--force]" >&2
  exit 2
fi
if [ ! -d "$TARGET" ]; then
  echo "target directory does not exist: $TARGET" >&2
  exit 2
fi

DEST="$TARGET/.claude"

# Drop-in directories (copied recursively) and loose files.
DIRS=(skills agents hooks shared)
FILES=(prompting.md statusline.sh)

copied=0
skipped=0

# Copy one file into DEST preserving its path relative to the toolkit root,
# skipping an existing destination unless --force was given.
copy_one() {
  local src="$1" rel="$2" dst="$DEST/$2"
  if [ -e "$dst" ] && [ "$FORCE" != "1" ]; then
    echo "  skip (exists): $rel"
    skipped=$((skipped + 1))
    return
  fi
  if [ "$DRY_RUN" = "1" ]; then
    echo "  copy: $rel"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  copy: $rel"
  fi
  copied=$((copied + 1))
}

echo "Toolkit: $SCRIPT_DIR"
echo "Target:  $DEST"
[ "$DRY_RUN" = "1" ] && echo "(dry-run: no files will be written)"
echo ""

# --- Recursive drop-in directories ---
for d in "${DIRS[@]}"; do
  [ -d "$SCRIPT_DIR/$d" ] || continue
  while IFS= read -r f; do
    rel="${f#"$SCRIPT_DIR"/}"
    copy_one "$f" "$rel"
  done < <(find "$SCRIPT_DIR/$d" -type f ! -name '.DS_Store')
done

# --- Loose top-level files ---
for f in "${FILES[@]}"; do
  [ -f "$SCRIPT_DIR/$f" ] && copy_one "$SCRIPT_DIR/$f" "$f"
done

# --- Config: never overwrite a real settings.json; drop the example beside it ---
[ -f "$SCRIPT_DIR/config/settings.example.json" ] && \
  copy_one "$SCRIPT_DIR/config/settings.example.json" "settings.example.json"

echo ""
echo "Done. copied=$copied skipped=$skipped"
echo ""
echo "Next steps:"
echo "  1. Merge $DEST/settings.example.json into $DEST/settings.json to wire the hooks + status line."
echo "  2. docs/ is reference material - read what you need to understand the pieces."
echo "  3. The root CLAUDE.md + AGENTS.md are behavioral reference (not auto-installed) - fold them into your own project's rules."
