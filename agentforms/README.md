# Agentforms

Agentforms are TypeScript sources for generating OpenCode configurations.

## Layout

- `default/config/` contains configuration shared by agents.
- `<agent>/config/` contains the agent-specific configuration.
- `<agent>/config/root.ts` is the single source of truth for that agent. It composes shared and agent-specific config.
- `<agent>/opencode.nix` defines the agent's Nix package.

Config modules use `@opencode-ai/sdk/v2` for types. Add MCP servers, models, or agents to their corresponding `config/*.ts` file.

## Run

Set the agentform root and run the agent package:

```bash
NIXAI_AGENTFORMS_ROOT="$PWD/agentforms" nix run .#oc-caelion
```

The wrapper runs `bun install`, then generates `agentforms/caelion/opencode.json` from `config/root.ts` before starting OpenCode. Manually changed generated files are backed up as `opencode.json.bak`.
