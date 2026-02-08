#!/bin/bash
# Hook: Sync INSTALLED plugins (not entire marketplace) to GitHub repo
# Triggered by Stop event — runs at end of every turn, checks for diffs
#
# Source of truth: ~/.claude/plugins/installed_plugins.json
# Plugin content:  ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/<name>/
# Stale plugins in the repo that are no longer installed get removed.

REPO_DIR="$HOME/claude-skills"
MANIFEST="$HOME/.claude/plugins/installed_plugins.json"
PLUGINS_SRC="$HOME/.claude/plugins/marketplaces/claude-plugins-official/plugins"
PLUGINS_CACHE="$HOME/.claude/plugins/cache/claude-plugins-official"
BACKUP_DIR="$HOME/skills-backup"

# Skip if repo or manifest doesn't exist
[ -d "$REPO_DIR/.git" ] || exit 0
[ -f "$MANIFEST" ] || exit 0

# Get list of installed plugin names from installed_plugins.json
installed_names=$(python3 -c "
import json, sys
with open('$MANIFEST') as f:
    data = json.load(f)
for key in sorted(data.get('plugins', {}).keys()):
    print(key.split('@')[0])
" 2>/dev/null)

[ -z "$installed_names" ] && exit 0

# Build sorted lists for comparison
installed_sorted=$(echo "$installed_names" | sort)
repo_sorted=$(ls "$REPO_DIR/plugins" 2>/dev/null | sort)

# Also check if the manifest itself changed
manifest_changed=false
if [ -f "$REPO_DIR/installed_plugins.json" ]; then
  if ! diff -q "$MANIFEST" "$REPO_DIR/installed_plugins.json" >/dev/null 2>&1; then
    manifest_changed=true
  fi
else
  manifest_changed=true
fi

# Quick check: if plugin lists match and manifest unchanged, nothing to do
if [ "$installed_sorted" = "$repo_sorted" ] && [ "$manifest_changed" = false ]; then
  exit 0
fi

# --- Something changed, do a full sync ---

mkdir -p "$REPO_DIR/plugins"
mkdir -p "$BACKUP_DIR/plugins"

# 1. Remove stale plugins from repo (installed previously but no longer in manifest)
for dir in "$REPO_DIR/plugins"/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  if ! echo "$installed_names" | grep -qx "$name"; then
    rm -rf "$REPO_DIR/plugins/$name"
  fi
done

# 2. Sync each installed plugin — try marketplace dir first, fall back to cache
for name in $installed_names; do
  src="$PLUGINS_SRC/$name"
  if [ -d "$src" ]; then
    rsync -a --delete "$src/" "$REPO_DIR/plugins/$name/"
    rsync -a --delete "$src/" "$BACKUP_DIR/plugins/$name/"
  elif [ -d "$PLUGINS_CACHE/$name" ]; then
    # Plugin only exists in cache (not in marketplace catalog)
    # Cache structure: <name>/<version>/ — find the first version dir with content
    cache_src=""
    for version_dir in "$PLUGINS_CACHE/$name"/*/; do
      [ -d "$version_dir" ] || continue
      # Check if version dir has any content (skip empty stubs)
      if [ "$(ls -A "$version_dir" 2>/dev/null)" ]; then
        cache_src="$version_dir"
        break
      fi
    done
    if [ -n "$cache_src" ]; then
      rsync -a --delete --exclude='.git' "$cache_src" "$REPO_DIR/plugins/$name/"
      rsync -a --delete --exclude='.git' "$cache_src" "$BACKUP_DIR/plugins/$name/"
    fi
    # If all version dirs are empty, skip silently (stub plugin with no files)
  fi
done

# 3. Copy the manifest for version tracking / restore
cp "$MANIFEST" "$REPO_DIR/installed_plugins.json"
cp "$MANIFEST" "$BACKUP_DIR/installed_plugins.json"

# 4. Also sync skills (in case both changed)
rsync -a --no-links --delete "$HOME/.claude/skills/" "$REPO_DIR/skills/"
for link in "$HOME/.claude/skills/"*/; do
  name=$(basename "$link")
  if [ -L "$HOME/.claude/skills/$name" ]; then
    cp -rL "$HOME/.claude/skills/$name" "$REPO_DIR/skills/$name" 2>/dev/null
  fi
done

# 5. Regenerate README
"$HOME/.claude/hooks/generate-readme.sh"

# 6. Commit and push
cd "$REPO_DIR"
git add -A
if ! git diff --cached --quiet; then
  # Summarize what changed
  added=$(diff <(echo "$repo_sorted") <(echo "$installed_sorted") | grep '^>' | sed 's/^> //' | tr '\n' ', ' | sed 's/,$//')
  removed=$(diff <(echo "$repo_sorted") <(echo "$installed_sorted") | grep '^<' | sed 's/^< //' | tr '\n' ', ' | sed 's/,$//')
  msg="Auto-backup: plugins synced"
  [ -n "$added" ] && msg="$msg — added: $added"
  [ -n "$removed" ] && msg="$msg — removed: $removed"
  git commit -m "$msg"
  git push origin main 2>/dev/null
fi

# Log
echo "$(date '+%Y-%m-%d %H:%M:%S') - Plugin sync complete (installed: $(echo "$installed_names" | wc -l | tr -d ' '))" >> "$BACKUP_DIR/backup.log"

exit 0
