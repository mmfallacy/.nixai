{ ... }:
{
  flake.builders.opencode =
    {
      lib,
      stdenvNoCC,
      makeWrapper,

      # Absolute Runtime Dependencies
      opencode,
      bun,
      generate-opencode-config,

      # Package Parameters
      name ? throw "name must be provided",

      sessionDirRoot ? "\${XDG_DATA_HOME:-$HOME/.local/share}",
      configRoot ? "\$NIXAI_AGENTFORMS_ROOT",
      runtimeDeps ? [ ],
      wrapperArgs ? [ ],
      binPrefix ? "",
    }:
    let
      # Pin config path to use agent name to prevent overriding
      # other agents unintentionally.
      configPath = "${configRoot}/${name}";
      binName = lib.optionalString (binPrefix != "") "${binPrefix}-" + name;
      sessionDir = "${sessionDirRoot}/${name}";
    in
    stdenvNoCC.mkDerivation {
      name = "opencode-${name}";

      # No src
      dontUnpack = true;

      nativeBuildInputs = [
        makeWrapper
        bun
      ];
      propagatedBuildInputs = [ ] ++ runtimeDeps;

      buildPhase =
        let
          checkAndSetConfigRootVar = # bash
            ''
              if [[ -z "${configRoot}" ]]; then
                echo "warning: ${configRoot} is unset! using untracked settings in \$XDG_CONFIG_HOME instead" >&2
                export OPENCODE_CONFIG_DIR="$XDG_CONFIG_HOME/${name}"
              else
                export OPENCODE_CONFIG_DIR="${configPath}"
              fi
            '';
          generateOpencodeConfig = # bash
            ''
              conf=$OPENCODE_CONFIG_DIR/config/root.ts
              out=$OPENCODE_CONFIG_DIR/opencode.json
              if [[ -f "$conf" ]]; then 
                echo "Generating opencode.json from config/root.ts"
                bun install --cwd "$OPENCODE_CONFIG_DIR"
                ${lib.getExe generate-opencode-config} "$conf" "$out"
              fi
            '';
        in
        ''
          runHook preBuild
          mkdir -p $out/bin

          makeWrapper ${lib.getExe opencode} "$out/bin/${binName}" \
            --run '${checkAndSetConfigRootVar}' \
            --run '${generateOpencodeConfig}' \
            --run 'export XDG_DATA_HOME="${sessionDir}"' \
            --set OPENCODE_DISABLE_LSP_DOWNLOAD true \
            --set OPENCODE_EXPERIMENTAL_LSP_TOOL true \
            ${lib.escapeShellArgs wrapperArgs}

          runHook postBuild
        '';
    };
}
