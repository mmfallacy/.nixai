top: {
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-caelion = pkgs.callPackage top.config.flake.piInstances.default {
        src = ./.;
        name = "pi-caelion";
      };
    };
}
