---
name: install-skill-module
description: Install selected skills from a shared skill repository into a Pi agent. Use when adding a skill repo as a submodule, sparse-checking only chosen skills and dependencies, and wiring those skills into an agent config with symlinks.
---

# Install Skill Module

Goal: install only the requested skills, plus dependencies, from a shared module into one Pi agent.

Layout:

```text
<config-root>/default/skill_modules/<module>/   # shared repo/submodule
<config-root>/<agent>/skills/<skill>/           # symlink to a single skill dir
```

Do not add a whole module `skills/` directory to `settings.json` unless the user explicitly asks. Symlink only the skills the agent should load.

## 1. Find the target agent config

Do not assume the current working directory is the config repo.

If the user gives an agent config path, use it. Otherwise, if the user gives an agent name, find its executable and read the wrapper:

```bash
AGENT_NAME=<agent-name>
AGENT_BIN="$(command -v "$AGENT_NAME")"
AGENT_BIN="$(readlink -f "$AGENT_BIN")"
grep '^export PI_CODING_AGENT_DIR=' "$AGENT_BIN"
```

Extract `PI_CODING_AGENT_DIR` from that shell script. Expand `~` to `$HOME`. That is `TARGET_AGENT_DIR`.

If no agent name/path is given, use the active agent:

```bash
TARGET_AGENT_DIR="${PI_CODING_AGENT_DIR/#\~/$HOME}"
```

If `TARGET_AGENT_DIR` points into `/nix/store` or another read-only/generated location, stop and ask for the writable source config path.

Then derive:

```bash
CONFIG_ROOT="$(dirname "$TARGET_AGENT_DIR")"
SHARED_MODULES_DIR="$CONFIG_ROOT/default/skill_modules"
CONFIG_GIT_ROOT="$(git -C "$CONFIG_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
```

Fellow agents are sibling directories under `CONFIG_ROOT`:

```bash
find "$CONFIG_ROOT" -mindepth 1 -maxdepth 1 -type d -print
```

Directories containing `settings.json`, `pi.nix`, `README.md`, or `skills/` are likely agent/config directories.

## 2. Establish inputs

You need:

- `SOURCE`: repo URL, GitHub shorthand like `github:owner/repo`, local path, or existing module path.
- `MODULE`: directory name under `SHARED_MODULES_DIR`.
- `REQUESTED_SKILLS`: skill names or paths to expose.
- `TARGET_AGENT_DIR`: absolute path found above.

Discover facts from files/repos instead of asking when possible.

Normalize `github:owner/repo` to `https://github.com/owner/repo.git` unless the user asks for SSH.

## 3. Install or reuse the module

Set:

```bash
MODULE_DIR="$SHARED_MODULES_DIR/$MODULE"
```

For a git repo source, install as a submodule:

```bash
mkdir -p "$SHARED_MODULES_DIR"
git -C "$CONFIG_GIT_ROOT" submodule add "$SOURCE" "$MODULE_DIR"
```

If `MODULE_DIR` already exists, reuse it. Check first:

```bash
git -C "$CONFIG_GIT_ROOT" status --short
git -C "$CONFIG_GIT_ROOT" submodule status --recursive
```

If moving an existing submodule, update `.gitmodules`, root `.git/config`, and the submodule gitdir `core.worktree`/`config.worktree` consistently.

## 4. Resolve skills and dependencies

Find each requested skill directory by locating `SKILL.md` files and matching frontmatter `name:` exactly. Prefer exact `name:` over directory name.

For each selected skill:

1. Read `SKILL.md`.
2. Look for required skill invocations, for example `Call the Skill tool for "name"`, `/skill:name`, or prose saying another skill is required.
3. Resolve each dependency the same way by exact frontmatter `name:`.
4. Repeat until no new dependencies appear.

If a dependency is ambiguous, ask the user. Do not guess.

## 5. Sparse checkout selected skill dirs

For git-backed modules, sparse-checkout only the requested skill dirs and dependency skill dirs:

```bash
git -C "$MODULE_DIR" sparse-checkout init --no-cone
git -C "$MODULE_DIR" sparse-checkout set \
  path/to/requested-skill \
  path/to/dependency-skill
```

Use `--no-cone` unless all selected directories fit cone mode cleanly. Avoid full checkout unless the user asks.

## 6. Symlink skills into the agent

For every requested skill and dependency:

```bash
mkdir -p "$TARGET_AGENT_DIR/skills"
LINK_DIR="$TARGET_AGENT_DIR/skills"
SKILL_TARGET="$MODULE_DIR/<path-to-skill>"
LINK_PATH="$LINK_DIR/<skill-name>"
REL_TARGET="$(realpath --relative-to="$LINK_DIR" "$SKILL_TARGET")"
ln -s "$REL_TARGET" "$LINK_PATH"
```

Conflict rules:

- Existing symlink to the same target: leave it.
- Existing symlink to a different target: stop unless user asked to replace.
- Existing real directory/file: stop unless user explicitly allows replacing it.

## 7. Verify

Filesystem resolution:

```bash
find -L "$TARGET_AGENT_DIR/skills" -maxdepth 2 -name SKILL.md -print
```

Sparse checkout:

```bash
git -C "$MODULE_DIR" sparse-checkout list
```

Pi discovery, with no LLM turn:

```bash
pi-check-skills "$TARGET_AGENT_DIR"
```

Confirm the output includes every requested skill and dependency by name.

If `pi-check-skills` is not on `PATH`, ask how helper scripts are exposed in this config. Do not assume the current working directory contains it.

## 8. Report

Report only:

- target agent path
- fellow agents found under `CONFIG_ROOT`
- module path
- sparse paths
- skill symlinks created/reused
- dependencies included
- `pi-check-skills` result
- whether the current running agent needs restart/reload to see new skills
