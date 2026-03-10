#!/usr/bin/env bash
# ClawMoney Skill - Automated Setup
# Installs all dependencies: bnbot skill, bnbot-mcp-server, MCP config

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }

NEEDS_RESTART=false

# --- 1. Check & install bnbot skill ---
echo "Checking bnbot skill..."
if clawhub list 2>/dev/null | grep -q "bnbot"; then
  ok "bnbot skill already installed"
else
  warn "bnbot skill not found, installing..."
  if clawhub install bnbot; then
    ok "bnbot skill installed"
  else
    fail "Failed to install bnbot skill. Run manually: clawhub install bnbot"
    exit 1
  fi
fi

# --- 2. Check & install bnbot-mcp-server ---
echo "Checking bnbot-mcp-server..."
if command -v bnbot-mcp-server &>/dev/null || npx --yes bnbot-mcp-server --version &>/dev/null 2>&1; then
  ok "bnbot-mcp-server available"
else
  warn "bnbot-mcp-server not found, installing..."
  if npm install -g bnbot-mcp-server; then
    ok "bnbot-mcp-server installed globally"
  else
    fail "Failed to install bnbot-mcp-server. Run manually: npm install -g bnbot-mcp-server"
    exit 1
  fi
fi

# --- 3. Check & configure MCP in .mcp.json ---
echo "Checking MCP configuration..."

# Find the project root (look for .mcp.json or package.json going upward)
find_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.mcp.json" ]] || [[ -f "$dir/package.json" ]]; then
      echo "$dir"
      return
    fi
    dir="$(dirname "$dir")"
  done
  echo "$PWD"
}

PROJECT_ROOT="$(find_project_root)"
MCP_FILE="$PROJECT_ROOT/.mcp.json"

if [[ -f "$MCP_FILE" ]]; then
  # Check if bnbot is already configured
  if python3 -c "
import json, sys
with open('$MCP_FILE') as f:
    data = json.load(f)
servers = data.get('mcpServers', {})
if 'bnbot' in servers:
    sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
    ok "MCP config already has bnbot server"
  else
    # Add bnbot to existing .mcp.json
    warn "Adding bnbot to existing .mcp.json..."
    python3 -c "
import json
with open('$MCP_FILE') as f:
    data = json.load(f)
if 'mcpServers' not in data:
    data['mcpServers'] = {}
data['mcpServers']['bnbot'] = {
    'command': 'npx',
    'args': ['bnbot-mcp-server']
}
with open('$MCP_FILE', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
"
    ok "Added bnbot MCP server to $MCP_FILE"
    NEEDS_RESTART=true
  fi
else
  # Create new .mcp.json
  warn "Creating .mcp.json..."
  cat > "$MCP_FILE" << 'MCPEOF'
{
  "mcpServers": {
    "bnbot": {
      "command": "npx",
      "args": ["bnbot-mcp-server"]
    }
  }
}
MCPEOF
  ok "Created $MCP_FILE with bnbot MCP server"
  NEEDS_RESTART=true
fi

# --- Summary ---
echo ""
echo "=== Setup Complete ==="
if $NEEDS_RESTART; then
  warn "MCP config was updated. Please restart Claude Code to activate the bnbot MCP connection."
  echo "  Then install the BNBot Chrome Extension if not already:"
  echo "  https://chromewebstore.google.com/detail/bnbot-your-ai-growth-agen/haammgigdkckogcgnbkigfleejpaiiln"
else
  ok "All dependencies ready!"
  echo "  Make sure the BNBot Chrome Extension is installed and MCP mode is enabled."
fi
