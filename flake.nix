{
  description = ".nixai";
  outputs =
    inputs@{ self, flake-parts, ... }:
    let
      inherit (inputs.nixpkgs) lib;
      shouldImport = file: file.hasExt "nix" && !(lib.hasPrefix "_" file.name);
      import-tree =
        path:
        lib.pipe path [
          (lib.fileset.fileFilter shouldImport)
          (lib.fileset.toList)
        ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      imports = lib.flatten [
        (import-tree ./nix)
      ];

      perSystem =
        { system, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          _module.args.extras = {

          };
        };
    };

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  };
}
