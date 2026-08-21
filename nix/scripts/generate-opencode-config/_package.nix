{
  stdenvNoCC,
  makeWrapper,
  bun,
  coreutils,
}:
stdenvNoCC.mkDerivation {
  name = "generate-opencode-config";

  src = ./.;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/bin"
    cp -r $src "$out/lib/generate-opencode-config"

    makeWrapper ${bun}/bin/bun "$out/bin/generate-opencode-config" \
      --add-flags "$out/lib/generate-opencode-config/index.ts" \
      --prefix PATH : ${coreutils}/bin

    runHook postInstall
  '';
}
