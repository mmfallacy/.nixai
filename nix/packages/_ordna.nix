{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs_26,
  pnpm_10,
  pnpmConfigHook,
  pnpmBuildHook,
  makeWrapper,
}:
let
  pnpm = pnpm_10;
  nodejs = nodejs_26;
in
stdenv.mkDerivation (finalAttrs: rec {
  pname = "ordna";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "FreHilm";
    repo = "ordna";
    tag = version;
    hash = "sha256-JMjO8YegDsVUqlWn8XyaDqgSoMXTlqs2sFKBI2dSgs8=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-5rErUp8FGNC/XLPh4VBjrXyFtso5EXEcbkgfIDAH9lE=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    pnpmBuildHook
    makeWrapper
  ];

  pnpmBuildScript = "build";
  pnpmBuildFlags = [
  ];

  postBuild = ''
    pnpm --filter @frehilm/ordna-web build:client
  '';

  installPhase = ''
    runHook preInstall

    echo "inject-workspace-packages=true" >> .npmrc

    mkdir -p "$out/lib"
    pnpm --offline --filter @frehilm/ordna-cli --prod deploy "$out/lib"
    mkdir -p "$out/bin"
    makeWrapper ${nodejs}/bin/node $out/bin/ordna \
      --add-flags "$out/lib/dist/bin/ordna.js"


    runHook postInstall
  '';

  dontStrip = true;
  dontPatchELF = true;
  dontRewriteSymlinks = true;

  meta = {
    description = "Local-first, git-based Kanban task board";
    homepage = "https://github.com/FreHilm/ordna";
    license = lib.licenses.mit;
    mainProgram = "ordna";
  };
})
