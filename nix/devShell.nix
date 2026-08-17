{
  perSystem =
    { pkgs, extras, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = ".nixai development shell";

        nativeBuildInputs = [
          pkgs.pi-coding-agent
          extras.mypkgs.ordna
          extras.mypkgs.pi-default
        ];

      };
    };
}
