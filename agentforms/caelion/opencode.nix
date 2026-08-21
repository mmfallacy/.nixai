top: {
  perSystem =
    { pkgs, ... }:
    {
      packages.oc-caelion = pkgs.callPackage top.config.flake.builders.opencode {
        name = "caelion";

        runtimeDeps = with pkgs; [
          fd
          fzf
        ];

      };
    };
}
