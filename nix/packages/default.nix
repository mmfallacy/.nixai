{
  perSystem =
    { pkgs, ... }:
    {
      packages.ordna = pkgs.callPackage ./_ordna.nix { };
    };

}
