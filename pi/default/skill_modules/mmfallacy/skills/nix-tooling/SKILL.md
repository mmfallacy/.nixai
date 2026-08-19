---
name: nix-tooling
description: Use Nix for temporary CLI tools, flake inspection, evaluation, and small approved edits.
---

Use Nix confidently across repositories while keeping the user's environment explicit and reproducible.

## Operating rules

- Assume an active development shell (often via `.envrc`/direnv). Check whether a required binary is already available before proposing Nix.
- Prefer modern one-shot commands: `nix shell <source>#<package> -c <command>`. Do not open an interactive shell unless asked.
- Confirm **every Nix command** before running it. The user may grant unmoderated Nix access for the current session; otherwise ask per command. Confirmation must show the exact command, purpose, network access, and whether it may materialize paths in the Nix store.
- Treat `nix eval` as read-only. Never use it to mutate anything.
- Never update `flake.lock`. If input updates are needed, ask the user to run `nix flake update` manually. For flake-based commands, pass `--no-write-lock-file` whenever supported so this policy is enforced by the command itself.
- Ask before modifying any Nix file. Make changes in small, easily reviewable chunks and show the intended diff/summary first.

## Source selection

1. Check the active shell and repository outputs first.
2. If `flake.nix` and `flake.lock` exist, inspect them and use a locked nixpkgs input for tooling. If there are multiple candidates (`nixpkgs-stable`, `nixpkgs-unstable`, or differently named inputs), ask which one to use. State the selected input in the command/explanation. Use the repository's input registry explicitly, for example:
   ```bash
   nix search --no-write-lock-file --inputs-from . <selected-input> '<regex>'
   nix shell --no-write-lock-file --inputs-from . <selected-input>#<package> -c <command>
   ```
3. Use `nix search` against that locked input to find packages. It searches package attribute names and descriptions, not necessarily executable names. Use focused regexes (for example, `^(jq|yq)$` or `git` with `--exclude 'python|gui'`); use `^` rather than `.*` when listing everything. Report candidate attributes and verify the executable with `meta.mainProgram` when available or `command -v` inside the temporary shell before claiming it is available.
4. If there is no flake/lockfile, assume the active devshell is authoritative. If a required binary is absent, ask whether the user wants to add it to the devshell manually or explicitly authorize a temporary `nix shell` fallback. Do not silently choose an unpinned nixpkgs.
5. Ask before searching broader nixpkgs when the locked input is insufficient.

## Flake work

For inspection, use appropriate read-only operations such as listing files, `nix flake show --no-write-lock-file`, `nix flake metadata --no-write-lock-file`, and targeted `nix eval --no-write-lock-file` (with confirmation). Inspect `flake.nix` and `flake.lock` to understand input names and pins; do not assume the input is literally named `nixpkgs`. `nix eval` must not mutate repository files or lockfiles, but it may access the network or materialize evaluation dependencies; disclose those effects during confirmation.

For edits, understand the existing style and choose the smallest appropriate output (`devShells`, `packages`, overlays, or module configuration). Obtain approval before each reviewable chunk. Do not modify or regenerate `flake.lock`.

## Typical workflow

1. Identify the needed command and check whether it is already present.
2. Inspect the repository's flake and lockfile, if present.
3. Resolve the locked nixpkgs input and search it with `nix search`.
4. Present the exact proposed command and store/network impact; obtain confirmation.
5. Run a one-shot `nix shell … -c …`, then verify the command.
6. If persistence is preferable, propose a small devshell/flake edit and obtain separate approval.

Keep explanations concise, distinguish persistent devshell changes from temporary tools, and never claim a package is available without checking.
