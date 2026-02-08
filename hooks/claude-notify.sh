#!/bin/bash
# Claude Code notification hook for Pop!_OS / GNOME
# Sends desktop notifications when Claude needs attention
#
# Receives JSON on stdin with fields:
#   hook_event_name, notification_type, message, title, session_id

# Read JSON from stdin
INPUT=$(cat)

# Parse fields using python3 (always available on Pop!_OS)
EVENT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('hook_event_name',''))" 2>/dev/null)
NOTIF_TYPE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('notification_type',''))" 2>/dev/null)
MESSAGE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','Claude needs attention'))" 2>/dev/null)
TITLE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title','Claude Code'))" 2>/dev/null)

# Pick icon and urgency based on event type
URGENCY="normal"
ICON="dialog-information"

SOUND="/usr/share/sounds/freedesktop/stereo/complete.oga"

case "$NOTIF_TYPE" in
  permission_prompt)
    ICON="dialog-password"
    URGENCY="critical"
    TITLE="Claude Code — Permission Needed"
    SOUND="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"
    ;;
  idle_prompt)
    ICON="dialog-question"
    URGENCY="normal"
    TITLE="Claude Code — Waiting for Input"
    SOUND="/usr/share/sounds/freedesktop/stereo/dialog-information.oga"
    ;;
  elicitation_dialog)
    ICON="dialog-question"
    URGENCY="normal"
    TITLE="Claude Code — Question"
    SOUND="/usr/share/sounds/freedesktop/stereo/dialog-information.oga"
    ;;
esac

# For Stop events (Claude finished responding)
if [ "$EVENT" = "Stop" ]; then
  ICON="dialog-information"
  URGENCY="normal"
  TITLE="Claude Code — Done"
  MESSAGE="Claude has finished responding"
  SOUND="/usr/share/sounds/freedesktop/stereo/complete.oga"
fi

# Send the notification
# --hint ensures it plays the notification sound
if command -v notify-send &>/dev/null; then
  notify-send \
    --urgency="$URGENCY" \
    --icon="$ICON" \
    --app-name="Claude Code" \
    --hint=string:desktop-entry:claude \
    "$TITLE" \
    "$MESSAGE"
else
  # Fallback: use gdbus directly if notify-send isn't installed
  gdbus call --session \
    --dest=org.freedesktop.Notifications \
    --object-path=/org/freedesktop/Notifications \
    --method=org.freedesktop.Notifications.Notify \
    "Claude Code" 0 "$ICON" "$TITLE" "$MESSAGE" '[]' '{}' 5000 \
    &>/dev/null
fi

exit 0
