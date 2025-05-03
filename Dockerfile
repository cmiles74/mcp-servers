FROM crystaldba/postgres-mcp

# Install Git and curl
RUN apt update
RUN apt install -yqq git curl

# install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash
RUN apt update
RUN apt install -yqq nodejs

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# install MCP proxy
RUN uv tool install mcp-proxy

# install MCP server inspector
RUN npm install -g @modelcontextprotocol/inspector

# install Git MCP Server
RUN git clone https://github.com/cyanheads/git-mcp-server.git
WORKDIR /git-mcp-server
RUN npm install
RUN npm run build
COPY ./config/git-mcp-server/env ./.env
WORKDIR /

# install DuckDuckGo MCP server
RUN uv pip install duckduckgo-mcp-server

COPY /scripts/* .

# MCP Proxy
EXPOSE 9099

# MCP Inspector
EXPOSE 6274

# MCP Inspector Proxy Server
EXPOSE 6277

# PostgreSQL MCP server
EXPOSE 9098

# Duck Duck Go MCP server
EXPOSE 9097

# Memory server
EXPOSE 9096

ENTRYPOINT ["./start.sh"]
