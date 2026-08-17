{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    attrsOf
    package
    functionTo
    ;
in
{
  options.flake = {
    piInstances = mkOption {
      type = attrsOf (functionTo package);
      default = { };
      description = "Pi Agent instances";
    };
  };
}
