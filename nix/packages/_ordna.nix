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

    mkdir -p "$out/lib/ordna"
    cp -r ./node_modules "$out/lib/ordna"
    cp ./package.json "$out/lib/ordna"
    cp ./pnpm-workspace.yaml "$out/lib/ordna"

    mkdir -p "$out/lib/ordna/packages/core"
    cp -r ./packages/core/dist "$out/lib/ordna/packages/core"
    cp -r ./packages/core/node_modules "$out/lib/ordna/packages/core"
    cp ./packages/core/package.json "$out/lib/ordna/packages/core"

    mkdir -p "$out/lib/ordna/packages/cli"
    cp -r ./packages/cli/dist "$out/lib/ordna/packages/cli"
    cp -r ./packages/cli/node_modules "$out/lib/ordna/packages/cli"
    cp ./packages/cli/package.json "$out/lib/ordna/packages/cli"

    mkdir -p "$out/lib/ordna/packages/web"
    cp -r ./packages/web/dist "$out/lib/ordna/packages/web"
    cp -r ./packages/web/dist-client "$out/lib/ordna/packages/web"
    cp -r ./packages/web/node_modules "$out/lib/ordna/packages/web"
    cp ./packages/web/package.json "$out/lib/ordna/packages/web"

    mkdir -p "$out/bin"
    makeWrapper ${nodejs}/bin/node $out/bin/ordna \
      --add-flags "$out/lib/ordna/packages/cli/dist/bin/ordna.js"

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
