{
  perSystem =
    { pkgs, extras, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = ".nixai development shell";

        nativeBuildInputs = [
          extras.mypkgs.ordna
          (extras.mypkgs.pi-default.override {
            agentConfig = "~/dev/.nixai/pi/default";
          })
        ];

      };
    };
}
