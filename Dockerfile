FROM ubuntu:rolling
RUN apt update

# install Git
RUN apt install -yqq git curl

# install Python uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh | bash
RUN apt install -yqq nodejs npm

# install MCP proxy
RUN uv tool install mcp-proxy

# install MCP server inspector
RUN npm install -g @modelcontextprotocol/inspector

# install Git MCP Server
RUN git clone https://github.com/cyanheads/git-mcp-server.git
WORKDIR git-mcp-server
RUN npm install
RUN npm run build
COPY ./config/git-mcp-server/env ./.env
WORKDIR /

COPY /scripts/* .

# MCP Proxy
EXPOSE 9099

# MCP Inspector
EXPOSE 6274

# MCP Inspector Proxy Server
EXPOSE 6277

ENTRYPOINT ./start.sh
