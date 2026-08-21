{
  perSystem =
    { pkgs, ... }:
    {
      packages.ordna = pkgs.callPackage ./_ordna.nix { };
      packages.opencode = pkgs.callPackage ./_opencode.nix { };
    };
}
