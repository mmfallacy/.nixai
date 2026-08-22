# Agentforms

Agentforms are TypeScript sources for generating OpenCode configurations.

## Layout

- `default/config/` contains configuration shared by agents.
- `<agent>/config/` contains the agent-specific configuration.
- `<agent>/config/root.ts` composes shared and agent-specific OpenCode config.
- `<agent>/index.ts` is the generator entrypoint. Its default export maps output filenames to JSON objects, such as `{ "opencode.json": root }`.
- `<agent>/opencode.nix` defines the agent's Nix package.

Config modules use `@opencode-ai/sdk/v2` for types. Add MCP servers, models, or agents to their corresponding `config/*.ts` file.

## Run

Set the agentform root and run the agent package:

```bash
NIXAI_AGENTFORMS_ROOT="$PWD/agentforms" nix run .#oc-caelion
```

The wrapper runs `bun install`, then generates all files from `agentforms/caelion/index.ts` into the agent's configuration directory before starting OpenCode. Each generated object contains a SHA-256 `hash`. Manually changed generated files are backed up as `<filename>.bak`; generation fails rather than replacing an existing backup.
