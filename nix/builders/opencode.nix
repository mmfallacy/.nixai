{ ... }:
{
  flake.builders.opencode =
    {
      lib,
      stdenvNoCC,
      makeWrapper,

      # Absolute Runtime Dependencies
      opencode,

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

      nativeBuildInputs = [ makeWrapper ];
      propagatedBuildInputs = [ ] ++ runtimeDeps;

      buildPhase =
        let
          checkAndSetConfigRootVar = # bash
            ''
              if [[ -z "${configRoot}" ]]; then
                echo "warning: ${configRoot} is unset! using untracked settings in \$XDG_CONFIG_HOME instead" >&2
              else
                export XDG_CONFIG_HOME="${configPath}"
              fi
            '';
        in
        ''
          runHook preBuild
          mkdir -p $out/bin

          makeWrapper ${lib.getExe opencode} "$out/bin/${binName}" \
            --run '${checkAndSetConfigRootVar}' \
            --run 'export XDG_DATA_HOME="${sessionDir}"' \
            --set OPENCODE_DISABLE_LSP_DOWNLOAD true \
            --set OPENCODE_EXPERIMENTAL_LSP_TOOL true \
            ${lib.escapeShellArgs wrapperArgs}

          runHook postBuild
        '';
    };
}
