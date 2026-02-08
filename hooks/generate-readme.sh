#!/bin/bash
# Generates README.md for the claude-skills repo from current skills and plugins

REPO_DIR="$HOME/claude-skills"
SKILLS_DIR="$REPO_DIR/skills"
PLUGINS_DIR="$REPO_DIR/plugins"
HOOKS_DIR="$REPO_DIR/hooks"
README="$REPO_DIR/README.md"

truncate_desc() {
  local text="$1"
  local max="${2:-80}"
  # Strip leading/trailing quotes and whitespace
  text=$(echo "$text" | sed 's/^["'"'"' ]*//' | sed 's/["'"'"' ]*$//')
  # Escape pipe chars for markdown tables
  text=$(echo "$text" | sed 's/|/\\|/g')
  if [ ${#text} -le "$max" ]; then
    echo "$text"
  else
    # Truncate at last word boundary before max
    echo "${text:0:$max}" | sed 's/ [^ ]*$/…/'
  fi
}

get_skill_description() {
  local skill_dir="$1"
  local skill_md="$skill_dir/SKILL.md"
  [ -f "$skill_md" ] || { echo "-"; return; }

  # Try frontmatter description: field first
  # Handle both inline (description: text) and multiline (description: |\n  text)
  desc=$(sed -n '/^---$/,/^---$/p' "$skill_md" | grep -m1 '^description:' | sed 's/^description: *//')
  if [ "$desc" = "|" ] || [ -z "$desc" ]; then
    # Multiline: grab the first indented line after "description:"
    desc=$(sed -n '/^---$/,/^---$/p' "$skill_md" | sed -n '/^description:/,/^[^ ]/p' | sed -n '2p' | sed 's/^ *//')
  fi
  if [ -n "$desc" ]; then
    truncate_desc "$desc"
    return
  fi

  # Fallback: first heading line after #
  desc=$(grep -m1 '^#' "$skill_md" | sed 's/^#* *//' | sed 's/ *— */: /')
  if [ -n "$desc" ]; then
    truncate_desc "$desc"
    return
  fi

  # Fallback: first non-empty non-heading line
  desc=$(grep -m1 -v '^\(#\|---\|$\)' "$skill_md" | head -1)
  if [ -n "$desc" ]; then
    truncate_desc "$desc"
    return
  fi

  echo "-"
}

get_plugin_description() {
  local plugin_dir="$1"
  local plugin_json="$plugin_dir/.claude-plugin/plugin.json"

  if [ -f "$plugin_json" ]; then
    desc=$(jq -r '.description // empty' "$plugin_json" 2>/dev/null)
    if [ -n "$desc" ]; then
      truncate_desc "$desc"
      return
    fi
  fi

  # Fallback: first heading in README.md
  local readme="$plugin_dir/README.md"
  if [ -f "$readme" ]; then
    desc=$(grep -m1 '^#' "$readme" | sed 's/^#* *//')
    if [ -n "$desc" ]; then
      truncate_desc "$desc"
      return
    fi
  fi

  echo "-"
}

# Count
skill_count=$(ls -d "$SKILLS_DIR"/*/ 2>/dev/null | wc -l)
plugin_count=$(ls -d "$PLUGINS_DIR"/*/ 2>/dev/null | wc -l)

# Generate
cat > "$README" << 'HEADER'
# Claude Code Skills & Plugins

Backup of my [Claude Code](https://claude.ai/claude-code) skills and plugins. Auto-synced via a PostToolUse hook whenever a skill or plugin is added or edited.

HEADER

echo "## Skills ($skill_count)" >> "$README"
echo "" >> "$README"
echo "| Skill | Description |" >> "$README"
echo "|-------|-------------|" >> "$README"

for dir in "$SKILLS_DIR"/*/; do
  name=$(basename "$dir")
  desc=$(get_skill_description "$dir")
  echo "| \`$name\` | $desc |" >> "$README"
done

echo "" >> "$README"
echo "## Plugins ($plugin_count)" >> "$README"
echo "" >> "$README"
echo "| Plugin | Description |" >> "$README"
echo "|--------|-------------|" >> "$README"

for dir in "$PLUGINS_DIR"/*/; do
  name=$(basename "$dir")
  desc=$(get_plugin_description "$dir")
  echo "| \`$name\` | $desc |" >> "$README"
done

cat >> "$README" << 'FOOTER'

## Auto-Backup

A PostToolUse hook watches for writes to `~/.claude/skills/` and `~/.claude/plugins/`. On any change it:

1. Syncs to a local backup at `~/skills-backup/`
2. Regenerates this README
3. Commits and pushes to this repo
FOOTER
