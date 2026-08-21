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
    builders = mkOption {
      type = attrsOf (functionTo package);
      default = { };
      description = "Agent recipes to create wrapper instances";
    };
  };
}
