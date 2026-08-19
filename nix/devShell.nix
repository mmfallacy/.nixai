{
  perSystem =
    { pkgs, extras, ... }:
    {
      devShells.default =
        let
          pi-unwrapped = pkgs.runCommand "pi-unwrapped" { } ''
            mkdir -p $out/bin
            ln -s ${pkgs.lib.getExe pkgs.pi-coding-agent} $out/bin/pi-unwrapped
          '';

        in
        pkgs.mkShell {
          name = ".nixai development shell";

          nativeBuildInputs = [
            pi-unwrapped
            extras.mypkgs.ordna
            (extras.mypkgs.pi-caelion.override {
              agentConfigRoot = "~/dev/.nixai/pi";
            })
          ];

        };
    };
}
