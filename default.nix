{pkgs}:
with pkgs; let
  manifest = (lib.importTOML ./Cargo.toml).package;
  inherit (manifest) name version;
  pname = name;
  src = lib.cleanSource ./.;
  assets = stdenv.mkDerivation {
    inherit src version;
    pname = "${pname}-assets";
    buildPhase = ''
      ${tailwindcss}/bin/tailwindcss -i styles/tailwind.css -o assets/main.css
    '';
    installPhase = ''
      mkdir -p $out
      mv assets $out/assets
    '';
  };
  unwrapped = rustPlatform.buildRustPackage {
    inherit src version;
    pname = "${pname}-unwrapped";
    cargoDeps = rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
    };
    cargoHash = "sha256-EYTuVD1SSk3q4UWBo+736Mby4nFZWFCim3MS9YBsrLc=";
    nativeBuildInputs = [pkg-config];
    buildInputs = [openssl];
  };
in
  writeShellScriptBin pname ''
    WEBSERVER_ASSETS=${assets}/assets ${unwrapped}/bin/webserver
  ''
