rec {
  flake.piInstances.default =
    {
      lib,
      stdenvNoCC,
      makeWrapper,
      fd,
      ripgrep,
      nodejs,
      pi-coding-agent,
      agentConfigRoot ? "${placeholder "out"}/share",
      sessionDir ? "",
      runtimeDeps ? [ ],
      wrapperArgs ? [ ],
      src ? throw "src must be provided",
      name ? throw "name must be provided",
      binPrefix ? "",
    }:
    let
      pi = pi-coding-agent;
      agentConfig = "${agentConfigRoot}/${name}";
      binName = lib.optionalString (binPrefix != "") "${binPrefix}-" + name;
    in
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit src;

      name = "pi-${name}";

      buildInputs = [ makeWrapper ];
      propagatedBuildInputs = [
        fd
        ripgrep

        nodejs
      ]
      ++ runtimeDeps;

      installPhase =
        let
          finalSessionDir = if sessionDir == "" then "$HOME/.pi/${finalAttrs.name}/sessions" else sessionDir;
        in
        # bash
        ''
          runHook preInstall

          mkdir -p $out/bin
          mkdir -p $out/share/${name}

          cp -r $src/. $out/share/${name}

          makeWrapper ${lib.getExe pi} $out/bin/${binName} \
            --set PI_CODING_AGENT_DIR "${agentConfig}" \
            --run 'export PI_CODING_AGENT_SESSION_DIR="${finalSessionDir}"' \
            ${lib.escapeShellArgs wrapperArgs}

          runHook postInstall
        '';

      # Temp: skill_modules introduction kinda broke reproducibility and isolation via nix store 😆
      dontCheckForBrokenSymlinks = true;
    });
}
