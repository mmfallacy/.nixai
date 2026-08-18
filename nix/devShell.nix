{
  perSystem =
    { pkgs, extras, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = ".nixai development shell";

        nativeBuildInputs = [
          extras.mypkgs.ordna
          (extras.mypkgs.pi-caelion.override {
            agentConfigRoot = "~/dev/.nixai/pi";
          })
        ];

      };
    };
}
