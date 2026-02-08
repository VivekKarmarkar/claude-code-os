#!/bin/bash
# Hook: Backup skills and plugins after any file write to ~/.claude/skills/ or plugins/
# Triggered by PostToolUse on Write|Edit events

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Trigger on writes to skills, plugins, hooks, or agents directory
if [[ "$FILE_PATH" == *"/.claude/skills/"* ]] || [[ "$FILE_PATH" == *"/.claude/plugins/"* ]] || [[ "$FILE_PATH" == *"/.claude/hooks/"* ]] || [[ "$FILE_PATH" == *"/.agents/"* ]]; then
  BACKUP_DIR="$HOME/skills-backup"

  mkdir -p "$BACKUP_DIR/custom-skills"
  mkdir -p "$BACKUP_DIR/plugins"
  mkdir -p "$BACKUP_DIR/downloaded-skills"

  # 1. Backup custom skills (exclude symlinks — those are handled separately)
  rsync -a --no-links --delete "$HOME/.claude/skills/" "$BACKUP_DIR/custom-skills/"

  # 2. Backup remotion-best-practices (follows the symlink to get actual files)
  if [ -L "$HOME/.claude/skills/remotion-best-practices" ]; then
    REMOTION_TARGET=$(readlink -f "$HOME/.claude/skills/remotion-best-practices")
    if [ -d "$REMOTION_TARGET" ]; then
      rsync -a --delete "$REMOTION_TARGET/" "$BACKUP_DIR/downloaded-skills/remotion-best-practices/"
    fi
  fi

  # 3. Backup all plugins
  PLUGINS_SRC="$HOME/.claude/plugins/marketplaces/claude-plugins-official/plugins"
  if [ -d "$PLUGINS_SRC" ]; then
    rsync -a --delete "$PLUGINS_SRC/" "$BACKUP_DIR/plugins/"
  fi

  # 4. Backup hooks
  mkdir -p "$BACKUP_DIR/hooks"
  rsync -a --delete "$HOME/.claude/hooks/" "$BACKUP_DIR/hooks/"

  # Log the backup
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Backed up skills+plugins after write to: $FILE_PATH" >> "$BACKUP_DIR/backup.log"

  # 4. Sync to GitHub repo and push
  REPO_DIR="$HOME/claude-skills"
  if [ -d "$REPO_DIR/.git" ]; then
    rsync -a --no-links --delete "$HOME/.claude/skills/" "$REPO_DIR/skills/"
    # Copy symlinked skills (e.g. remotion-best-practices)
    for link in "$HOME/.claude/skills/"*/; do
      name=$(basename "$link")
      if [ -L "$HOME/.claude/skills/$name" ]; then
        cp -rL "$HOME/.claude/skills/$name" "$REPO_DIR/skills/$name" 2>/dev/null
      fi
    done
    # Copy all plugins
    PLUGINS_SRC="$HOME/.claude/plugins/marketplaces/claude-plugins-official/plugins"
    if [ -d "$PLUGINS_SRC" ]; then
      mkdir -p "$REPO_DIR/plugins"
      rsync -a --delete "$PLUGINS_SRC/" "$REPO_DIR/plugins/"
    fi
    # Copy hooks
    mkdir -p "$REPO_DIR/hooks"
    rsync -a --delete "$HOME/.claude/hooks/" "$REPO_DIR/hooks/"
    # Regenerate README
    "$HOME/.claude/hooks/generate-readme.sh"
    cd "$REPO_DIR"
    git add -A
    if ! git diff --cached --quiet; then
      git commit -m "Auto-backup: skill updated - $(basename "$FILE_PATH")"
      git push origin main 2>/dev/null
    fi
  fi
fi

exit 0
