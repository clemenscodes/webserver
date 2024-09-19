{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
    lpi = {
      url = "github:cymenix/lpi";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    lpi,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        inherit (nixpkgs) lib;
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {inherit system lib overlays;};
        rustToolchain = with pkgs;
          (pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml).override {
            extensions = ["rust-src" "clippy" "llvm-tools"];
          };
        buildInputs = with pkgs; [pkg-config];
        nativeBuildInputs = with pkgs; [
          rustToolchain
          rust-analyzer
          openssl
          proto
          nix-output-monitor
          lpi.packages.${pkgs.system}.default
        ];
      in {
        packages = {
          default = import ./default.nix {inherit pkgs;};
        };
        apps = {
          default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/kickbase";
          };
        };
        devShells = {
          default = pkgs.mkShell {
            inherit buildInputs nativeBuildInputs;
            RUST_BACKTRACE = 1;
            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
            shellHook = ''
              proto setup --no-modify-profile
              proto use
              moon setup
              export PATH="$HOME/.moon/bin:/$HOME/.proto/bin:$PATH"
              export MOON="$(pwd)"
            '';
          };
        };
        formatter = pkgs.alejandra;
      }
    );
}
