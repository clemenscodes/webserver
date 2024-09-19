{pkgs}:
with pkgs; let
  manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
  inherit (manifest) name version;
  pname = name;
  src = pkgs.lib.cleanSource ./.;
  assets = pkgs.stdenv.mkDerivation {
    inherit src version;
    pname = "${pname}-assets";
    buildPhase = ''
      ${pkgs.tailwindcss}/bin/tailwindcss -i styles/tailwind.css -o assets/main.css
    '';
    installPhase = ''
      mkdir -p $out
      mv assets $out/assets
    '';
  };
  webserver-unwrapped = rustPlatform.buildRustPackage {
    inherit src version;
    pname = "${pname}-unwrapped";
    cargoDeps = rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
    };
    cargoHash = "sha256-TcHOR/IWy7J77QKzYsLAvBc8UVE77Vbl06HzjywiFns=";
    nativeBuildInputs = [pkg-config];
    buildInputs = [openssl];
  };
in
  writeShellScriptBin pname ''
    WEBSERVER_ASSETS=${assets}/assets ${webserver-unwrapped}/bin/webserver
  ''
