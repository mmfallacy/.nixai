rec {
  flake.piInstances.default =
    {
      lib,
      stdenvNoCC,
      makeWrapper,
      fd,
      ripgrep,
      pi-coding-agent,
      agentConfigRoot ? "${placeholder "out"}/share",
      sessionDir ? "",
      runtimeDeps ? [ ],
      wrapperArgs ? [ ],
      src ? throw "src must be provided",
      name ? throw "name must be provided",
    }:
    let
      pi = pi-coding-agent;
      agentConfig = "${agentConfigRoot}/${name}";
    in
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit src;

      name = "pi-${name}";

      buildInputs = [ makeWrapper ];
      propagatedBuildInputs = [
        fd
        ripgrep
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
      packages.pi-default = pkgs.callPackage flake.piInstances.default {
        src = ./.;
        name = "default";
      };
    };
}
