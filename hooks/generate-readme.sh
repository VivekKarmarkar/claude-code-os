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
hook_count=$(ls "$HOOKS_DIR"/*.sh 2>/dev/null | wc -l)

# Generate
cat > "$README" << 'HEADER'
# Claude Code OS for VivekKmk

Backup of my [Claude Code](https://claude.ai/claude-code) skills, plugins, and hooks. Auto-synced whenever a skill, plugin, or hook is added or edited.

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

echo "" >> "$README"
echo "## Hooks ($hook_count)" >> "$README"
echo "" >> "$README"
echo "| Hook | Description |" >> "$README"
echo "|------|-------------|" >> "$README"

for script in "$HOOKS_DIR"/*.sh; do
  [ -f "$script" ] || continue
  name=$(basename "$script")
  # Extract description from the first comment line after shebang
  desc=$(sed -n '2s/^# *//p' "$script")
  if [ -n "$desc" ]; then
    desc=$(truncate_desc "$desc")
  else
    desc="-"
  fi
  echo "| \`$name\` | $desc |" >> "$README"
done

cat >> "$README" << 'FOOTER'

## Auto-Backup

Hooks watch for changes to `~/.claude/skills/`, `~/.claude/plugins/`, and `~/.claude/hooks/`. On any change:

1. Syncs to a local backup at `~/skills-backup/`
2. Regenerates this README
3. Commits and pushes to this repo
FOOTER
