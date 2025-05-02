#!/bin/bash
trap 'kill $BGPID; exit' 0

export PATH="$PATH:./git-mcp"

/root/.local/bin/mcp-proxy --sse-port 9099 --sse-host 0.0.0.0 --pass-environment /git-mcp &
npx -y @modelcontextprotocol/inspector &
BGPID=$!
echo "MCP Inspector running with PID $BGPID"

wait
