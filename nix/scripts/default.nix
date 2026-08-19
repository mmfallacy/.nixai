{
  perSystem =
    { pkgs, ... }:
    {
      packages."scripts:pi-check-skills" = pkgs.callPackage ./_pi-check-skills.nix { };
    };
}
