# MCP Servers

This project provides a Docker container image that includes several MCP servers that might be useful to a variety of projects. This is early days for this project and not all of these servers have been thoroughly tested, use with caution. 🧯

## Building the Image

We have a script to build the image, it should run without issue.

    ./build.sh

This will create the image `docker-mcp-server:latest` in your local repository.

## Running the Image

We provide a shell script that start up the image, `start-mcp-servers`. You may then call that script from anywhere, this will be easiest if you add it to your `PATH` but you don't have to.

    cd ~/path/to/healthmatters
    ~/source/repos/docker-mcp-servers/start-mcp-servers

The script will map the current directory into the `/project` directory in the container. From the point of view of the tools that use the `STDIO` protocol, your project will be in the `/project` directory.

## Tools Provided

In addition to the MCP servers we also project an inspector tool running on port 6274. You may use this tool to see what tools the MCP servers are providing. Once the container is started you can interact with the inspector at...

* [http://localhost:6274/](http://localhost:6274/)

To keep things simple we've included scripts for the tools at the root of the image, that is, to run the Git MCP tool the command is `./git-mcp`. To see what tools the Git MCP server provides you'd select "STDIO" as the transport type in the upper-left and then type "./git-mcp" into the "Command" field and then press the "Connect" button. The list of tools should then be displayed in the middle column, selecting any tool from that middle column will let you add arguments and invoke it in the third column.

We also provide a proxy that will wrap tools that use standard IO so that they will work more easily from tools like Cursor. For the tools in this project that use STDIO (like the Git tool) we are have a proxy configured and running in the container.

### Configuring Cursor

When you select "Cursor Settings" from the "Settings" sub-menu of the Cursor application menu, you will be presented with all of the cursor settings. Select "MCP" from the left-hand navigation menu, all of your configured MCP servers will now be listed in the main panel. When you click on the "+ Add new global MCP Server" button in the upper-right hand corner, the MCP configuration file will open; it's just a big blob of JSON.

You may replace it with the configuration below or add the servers below to your existing configuration. When you save the file the tools will become available in the "MCP" section of Cursor's settings, you must then visit that setting page and enabled each one.

```json
{
  "mcpServers": {
      "git": {
          "type": "sse",
          "url": "http://localhost:9099/sse"
      }
  }
}
```

### Tool Notes

Below are some things to keep in mind when using the tools. 😉

#### Git

The Git MCP server is configured such that the directory from which you start the container (your working directory when you run `start-mcp-servers`) is the project directory. This is then mapped to `/project` in the container and the LLM doesn't always figure this out on it's own. I've found I have to start with a prompt that let's it know that the project loaded in Cursor is "/project" for the Git tool, something like...

> You have an MCP server named "git" configured, it may be used to manipulate this proect. This server is configured such that the path to this project is "/project".

This works okay but I suspect it could be better. If you think of a smoother way to map the project in, please submit a PR!

