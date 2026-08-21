# OpenCode Builder

## Purpose

`opencode.nix` defines a reusable flake builder for packaging OpenCode as an
agent-specific executable. It configures separate locations for each agent's
settings and session data, while ensuring the required runtime tools are
available.

## Usage

Call the builder with `pkgs.callPackage` and provide an agent `name`:

```nix
pkgs.callPackage top.config.flake.builders.opencode {
  name = "caelion";
  runtimeDeps = with pkgs; [ fd fzf ];
}
```

This produces a wrapped executable named after `name` (`caelion` in this
example).

The generated wrapper:

- Uses separate configuration and session directories for the agent.
- Disables automatic LSP downloads.
- Enables OpenCode's experimental LSP tool.

`runtimeDeps` adds tools required by the agent. `wrapperArgs` supplies
additional `makeWrapper` options, and `binPrefix` optionally prefixes the
generated executable name.
