#!/bin/bash
# Export MCP server configs (with secrets redacted) to the repo

REPO_DIR="$HOME/claude-skills"
CLAUDE_JSON="$HOME/.claude.json"

[ -f "$CLAUDE_JSON" ] || exit 0
[ -d "$REPO_DIR/.git" ] || exit 0

python3 -c "
import json, sys
with open('$CLAUDE_JSON') as f:
    data = json.load(f)
servers = data.get('mcpServers', {})
for name, cfg in servers.items():
    env = cfg.get('env', {})
    for k, v in env.items():
        if any(s in v.lower() for s in ['sk_', 'api_', 'key_', 'secret_', 'token_']) or any(s in k.lower() for s in ['api_key', 'secret', 'token', 'password']):
            env[k] = 'REDACTED'
with open('$REPO_DIR/mcp-servers.json', 'w') as f:
    json.dump(servers, f, indent=2)
    f.write('\n')
"
