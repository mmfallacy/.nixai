rec {
  flake.piInstances.default =
    {
      lib,
      stdenvNoCC,
      makeWrapper,
      fd,
      ripgrep,
      pi-coding-agent,
      agentConfig ? "${placeholder "out"}/share",
      sessionDir ? "",
      runtimeDeps ? [ ],
      wrapperArgs ? [ ],
    }:
    let
      pi = pi-coding-agent;
    in
    stdenvNoCC.mkDerivation (finalAttrs: {
      name = "pi-default";
      buildInputs = [ makeWrapper ];
      propagatedBuildInputs = [
        fd
        ripgrep
      ]
      ++ runtimeDeps;

      src = ./.;

      installPhase =
        let
          finalSessionDir = if sessionDir == "" then "$HOME/.pi/${finalAttrs.name}/sessions" else sessionDir;
        in
        # bash
        ''
          runHook preInstall

          mkdir -p $out/bin
          mkdir -p $out/share

          cp -r $src $out/share

          makeWrapper ${lib.getExe pi} $out/bin/pi \
            --set PI_CODING_AGENT_DIR "${agentConfig}" \
            --run 'export PI_CODING_AGENT_SESSION_DIR="${finalSessionDir}"' \
            ${lib.escapeShellArgs wrapperArgs}

          runHook postInstall
        '';
    });
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-default = pkgs.callPackage flake.piInstances.default { };
    };
}
