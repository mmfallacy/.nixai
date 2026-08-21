{
  # add overlays only on demand
  flake.overlays.internal-scripts = final: _prev: {
    generate-opencode-config = final.callPackage ./generate-opencode-config/_package.nix { };
  };

  perSystem =
    { pkgs, ... }:
    {
      packages."scripts:pi-check-skills" = pkgs.callPackage ./_pi-check-skills.nix { };
      packages."scripts:generate-opencode-config" =
        pkgs.callPackage ./generate-opencode-config/_package.nix
          { };
    };
}
