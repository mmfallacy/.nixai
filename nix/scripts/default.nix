{
  perSystem =
    { pkgs, ... }:
    {
      packages."scripts:pi-check-skills" = pkgs.callPackage ./_pi-check-skills.nix { };
      packages."scripts:generate-opencode-config" =
        pkgs.callPackage ./generate-opencode-config/_package.nix
          { };
    };
}
