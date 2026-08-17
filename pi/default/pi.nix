rec {
  flake.piInstances.default =
    {
      lib,
      stdenvNoCC,
      makeWrapper,
      fd,
      ripgrep,
      pi-coding-agent,
      agentHome ? "${placeholder "out"}/share",
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

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        mkdir -p $out/share

        cp -r $src $out/share

        makeWrapper ${lib.getExe pi} $out/bin/pi \
          --set PI_CODING_AGENT_DIR "${agentHome}" \
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
