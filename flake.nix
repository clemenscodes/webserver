{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    with inputs;
      flake-utils.lib.eachDefaultSystem (
        system: let
          inherit (nixpkgs) lib;
          overlays = [(import rust-overlay)];
          filter = nix-filter.lib;
          pkgs = import nixpkgs {inherit system lib overlays;};
          bin = pkgs.pkgsBuildHost.rust-bin;
          rustToolchain = bin.fromRustupToolchainFile ./rust-toolchain.toml;
          extendedRustToolchain = rustToolchain.override {
            extensions = [
              "rust-src"
              "clippy"
              "llvm-tools"
            ];
          };
        in
          with pkgs; {
            packages = {
              default = import ./default.nix {inherit pkgs filter;};
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

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://clemenscodes.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "clemenscodes.cachix.org-1:yEwW1YgttL2xdsyfFDz/vv8zZRhRGMeDQsKKmtV1N18="
    ];
  };
}
