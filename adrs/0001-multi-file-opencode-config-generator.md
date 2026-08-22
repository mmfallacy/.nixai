# Generate Multiple OpenCode Configuration Files

- Status: Proposed
- Date: 2026-08-22

## Context

`nix/scripts/generate-opencode-config` currently loads one TypeScript module,
reads its default-exported JSON object, and writes one `opencode.json` file.
It also embeds a SHA-256 hash in the generated object. On subsequent runs, the
hash is used to detect manual changes. A manually changed generated file is
moved to a `.bak` file before it is replaced.

OpenCode and its plugins may require several JSON files, including:

- `opencode.json`
- `tui.json`
- `model-aliases.json`

These files should be generated from one agentform entrypoint while retaining
the existing protection against silently overwriting manual changes.

## Decision

Promote the generator to a directory-oriented generator. Its interface will
be:

```text
generate-opencode-config <agentforms/index.ts> <output-directory>
```

The entrypoint must default-export a named record of file entries:

```ts
export default {
  opencode: { file: "opencode.json", value: opencode },
  tui: { file: "tui.json", value: tui },
  modelAliases: { file: "model-aliases.json", value: modelAliases },
};
```

The generator will create one file for each record entry. The record key names
the entry, `file` is the output filename, and `value` is the file contents.

Each generated JSON object will contain a `hash` property. The hash will be
computed using canonical JSON and SHA-256 after removing any existing `hash`
property. This preserves the current hash format and allows each generated
file to validate itself without a sidecar file.

For every output file:

1. Load and validate the generated value as a JSON object.
2. Compute and assign its hash.
3. If the output does not exist, write it.
4. If the output exists and its embedded hash matches its contents, replace it
   normally.
5. If the output exists but its hash does not match, move it to
   `<filename>.bak` and then write the generated file.
6. Fail if the required backup file already exists.

The generator will preflight all entries, output paths, existing JSON files,
and backup-file conflicts before modifying any output. This prevents a later
validation failure from leaving the output directory partially generated.

Filenames must resolve beneath the output directory. Absolute paths and path
traversal keys such as `../config.json` will be rejected. The `hash` property
is reserved and is overwritten by the generator.

The OpenCode builder will pass the agentform `index.ts` and
`$OPENCODE_CONFIG_DIR` to the generator instead of hard-coding
`config/root.ts` and `opencode.json`.

This gives each agentform one source for all generated OpenCode files while
preserving the current protection against overwriting manual changes. Embedded
hashes keep each file self-contained and avoid maintaining separate metadata.

Generated files must tolerate the reserved `hash` property.

## Implementation Plan

- Change the generator CLI from an output file argument to an output directory
  argument.
- Load the entrypoint's default export and validate the named file-entry
  record.
- Extract hash calculation and existing-file comparison into per-file logic.
- Add preflight validation before moving or writing files.
- Update `nix/builders/opencode.nix` to invoke the new interface.
- Add agentform `index.ts` entrypoints that export the required file map.
- Update the agentforms README with the new layout and backup behavior.
- Add tests for multiple files, matching hashes, modified files, backup
  conflicts, invalid exports, and unsafe filenames.

## Rejected Alternatives

- **Sidecar hash files:** Rejected because they add generated state and make
  each configuration file depend on separate metadata.
- **One generator invocation per file:** Rejected because it duplicates
  setup and makes the agentform's complete output less explicit.
