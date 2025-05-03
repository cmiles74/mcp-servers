#!/bin/bash
trap 'kill $BGPID_INSP; kill $BGPID_PGSQL; exit' 0

export PATH="$PATH:./git-mcp"

git config --global --add safe.directory /project

/root/.local/bin/mcp-proxy --sse-port 9099 --sse-host 0.0.0.0 --pass-environment /git-mcp &

/root/.local/bin/mcp-proxy --sse-port 9097 --sse-host 0.0.0.0 --pass-environment /ddg-mcp &

/root/.local/bin/mcp-proxy --sse-port 9096 --sse-host 0.0.0.0 --pass-environment /knowledge-graph &

npx -y @modelcontextprotocol/inspector &
BGPID_INSP=$!

postgres-mcp --access-mode=unrestricted --transport=sse --sse-host=0.0.0.0 --sse-port=9098 $MCP_DATABASE_URI &
BGPID_PGSQL=$!

wait
