{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (
    system: let
      inherit (nixpkgs) lib;
      overlays = [(import rust-overlay)];
      pkgs = import nixpkgs { inherit system lib overlays; };
      bin = pkgs.pkgsBuildHost.rust-bin;
      rustToolchain = bin.fromRustupToolchainFile ./rust-toolchain.toml;
      extendedRustToolchain = rustToolchain.override {
        extensions = [
          "rust-src"
          "clippy"
          "llvm-tools"
        ];
      };
    in with pkgs; {
      packages = {
        default = import ./default.nix { inherit pkgs; };
      };
      devShells = {
        default = mkShell {
          buildInputs = [pkg-config];
          nativeBuildInputs = [
            extendedRustToolchain
            rust-analyzer
            openssl
          ];
          RUST_SRC_PATH = "${rust.packages.stable.rustPlatform.rustLibSrc}";
          RUST_BACKTRACE = 1;
        };
      };
    }
  );
}
