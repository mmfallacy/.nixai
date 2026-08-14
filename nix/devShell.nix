{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = ".nixai development shell";

        nativeBuildInputs = [
        ];

      };
    };
}
