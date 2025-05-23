# MCP Servers

This project provides a Docker container image that includes several MCP servers that might be useful to a variety of projects. This is early days for this project and not all of these servers have been thoroughly tested, use with caution. 🧯 Right now the following functionality is provided...

* [Git repository, with history](https://github.com/cyanheads/git-mcp-server)
* [PostgreSQL Database server](https://github.com/cyanheads/git-mcp-server)
* [Internet Search](https://github.com/nickclyde/duckduckgo-mcp-server)
* [Remember stuff between sessions](https://github.com/shaneholloman/mcp-knowledge-graph)

## Use the Published Image

The easiest thing to do is to pull and run the published image. Navigate to the directory of the project you'd like to work with and run the following Docker command.

```shell
docker run -it --rm \
       -p 6274:6274 -p 6277:6277 -p 9099:9099 -p 9098:9098 -p 9097:9097 -p 9096:9096 \
       -v ./:/project -v ./.memory:/memory \
       -e MEMORY_FILE_PATH=./.memory \
       --add-host=host.docker.internal:host-gateway \
       --env-file ./.env \
       --name mcp-servers ghcr.io/cmiles74/docker-mcp-servers:latest
```

We map the ports that provide the MCP servers we'd like to expose to Cursor as well as the two ports used by the MCP server inspection tool. We map in our project and set the path for the LLM to store it's "memory" (a JSON file of data). We read in the project's `.env` file to get a connection string to the database and then we start up the container with the MCP servers.

You can find this script as well as another for Podman in the [`scripts` directory](scripts).


## Building the Image

You can also check-out the project and build the image locally it should run without issue.

    ./build.sh

This will create the image `docker-mcp-server:latest` in your local repository.

## Running the Image

We provide a shell script that start up the image, `start-mcp-servers`. You may then call that script from anywhere, this will be easiest if you add it to your `PATH` but you don't have to.

    cd ~/path/to/your-project
    ~/source/repos/docker-mcp-servers/start-mcp-servers

The script will map the current directory into the `/project` directory in the container. From the point of view of the tools that use the `STDIO` protocol, your project will be in the `/project` directory.

Lastly, the start script will name the container "mcp-servers". This makes it easy to call out and run commands inside the running container. To get a shell in the running container, you could...

    docker exec -it mcp-servers bash

## Tools Provided

In addition to the MCP servers we also project an inspector tool running on port 6274. You may use this tool to see what tools the MCP servers are providing. Once the container is started you can interact with the inspector at...

* [http://localhost:6274/](http://localhost:6274/)

We also provide a proxy that will wrap tools that use standard IO so that they will work more easily from tools like Cursor.

### Configuring Cursor

When you select "Cursor Settings" from the "Settings" sub-menu of the Cursor application menu, you will be presented with all of the cursor settings. Select "MCP" from the left-hand navigation menu, all of your configured MCP servers will now be listed in the main panel. When you click on the "+ Add new global MCP Server" button in the upper-right hand corner, the MCP configuration file will open; it's just a big blob of JSON.

You may replace it with the configuration below or add the servers below to your existing configuration. When you save the file the tools will become available in the "MCP" section of Cursor's settings, you must then visit that setting page and enabled each one.

```json
{
  "mcpServers": {
    "git": {
      "type": "sse",
      "url": "http://localhost:9099/sse"
    },
    "postgres": {
      "type": "sse",
      "url": "http://localhost:9098/sse"
    },
    "ddg-search": {
      "type": "sse",
      "url": "http://localhost:9097/sse"
    },
    "knowledge-graph": {
      "type": "sse",
      "url": "http://localhost:9096/sse"
    }
  }
}
```

You may also setup a set of "rules" that will be provided to the LLM along with every request. These rules may be used to steer the LLM, you might add some information about these MCP tools so that you don't need to include it in every prompt. We've included a sample rule set to get you started.
* [Sample Cursor Rules](rules-example.md)

### Tool Notes

Below are some things to keep in mind when using the tools. 😉

#### Git

The Git MCP server is configured such that the directory from which you start the container (your working directory when you run `start-mcp-servers`) is the project directory. This is then mapped to `/project` in the container and the LLM doesn't always figure this out on it's own. I've found I have to start with a prompt that let's it know that the project loaded in Cursor is "/project" for the Git tool, something like...

> You have an MCP server named "git" configured, it may be used to manipulate this proect. This server is configured such that the path to this project is "/project".

This works okay but I suspect it could be better. If you think of a smoother way to map the project in, please submit a PR!

#### PostgreSQL

When you run `start-mcp-servers` in your project directory the `.env` file at the root of that directory will be read. The PostgreSQL MCP server is looking for a connection string in an environment variable named `MCP_DATABASE_URI`, this is what it will use to connect to your database. Since we're running the tool in a Docker container the database hostname needs to point to your local machine, "host.docker.internal".

    MCP_DATABASE_URI=postgresql://DB_ACCOUNT:DB_PASSWORD@host.docker.internal:5432/DB_NAME

There's a sample in the `env-sample` folder. You will want to either create a `.env` file for your project if it doesn't have one or add this new variable to the bottom. You can then start the MCP servers and it will pickup that connection string and connect to your database.

You may have to remind the LLM that the tool for working with the database is present, I found a prompt that starts with something like the snipped below works well.

> There are a lot of tables in this project, you can use the "postgres" MCP tool to view them. Most of our tables are in the "super_interesting" schema.
