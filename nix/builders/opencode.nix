{ }:
{
  flake.builders.opencode =
    {
      lib,
      stdenvNoCC,
      makeWrapper,

      # Absolute Runtime Dependencies
      opencode,

      # Package Parameters
      configRoot ? throw "config root must be provided",
      sessionDirRoot ? "\${XDG_DATA_HOME:-$HOME/.local/share}",
      runtimeDeps ? [ ],
      wrapperArgs ? [ ],
      name ? throw "name must be provided",
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

      buildPhase = ''
        runHook preBuild
        mkdir -p $out/bin

        makeWrapper ${lib.getExe opencode} "$out/bin/${binName}" \
          --set XDG_CONFIG_HOME "${configPath}" \
          --set OPENCODE_DISABLE_LSP_DOWNLOAD true \
          --set OPENCODE_EXPERIMENTAL_LSP_TOOL true \
          --run 'export XDG_DATA_HOME="${sessionDir}"' \
          ${lib.escapeShellArgs wrapperArgs}

        runHook postBuild
      '';
    };
}
