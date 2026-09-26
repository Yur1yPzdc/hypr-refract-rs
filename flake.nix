{
  description = "Rust development flake using Crane and Oxalica Rust Overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # 1. Oxalica's rust-overlay for custom/pinned Rust toolchains
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 2. Crane for incremental Cargo building
    crane = {
      url = "github:ipetkov/crane";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Apply the oxalica overlay to nixpkgs
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        # Choose your Rust toolchain via oxalica's overlay:
        # Options: pkgs.rust-bin.stable.latest, pkgs.rust-bin.selectLatestNightlyWith, etc.
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ 
            "rust-src" 
            "rust-analyzer" 
            "clippy" 
            "llvm-tools-preview"
          ];
        };

        # Tell Crane to use your custom Oxalica Rust toolchain instead of the nixpkgs default
        craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

        # Clean source filter (keeps only Cargo.toml, Cargo.lock, and rust files)
        src = craneLib.cleanCargoSource ./.;

        # Shared dependencies and environment across builds and devshell
        commonArgs = {
          inherit src;
          strictDeps = true;

          # System libraries required at build time (e.g. OpenSSL, zlib)
          buildInputs = with pkgs; [
            # openssl
            # pkg-config
          ];

          # Native build tools (e.g. cmake, pkg-config)
          nativeBuildInputs = with pkgs; [
            # pkg-config
          ];
        };

        # Build workspace dependencies ONCE and cache them as a derivation
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

        # Build the actual crate using the cached artifacts
        myPackage = craneLib.buildPackage (commonArgs // {
          inherit cargoArtifacts;
        });
      in
      {
        # --- Packages (`nix build`) ---
        packages = {
          default = myPackage;
        };

        # --- Checks (`nix flake check`) ---
        checks = {
          inherit myPackage;

          # Parallel CI checks sharing the same cached cargoArtifacts
          my-crate-clippy = craneLib.cargoClippy (commonArgs // {
            inherit cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          });

          my-crate-fmt = craneLib.cargoFmt { inherit src; };

          my-crate-tests = craneLib.cargoNextest (commonArgs // {
            inherit cargoArtifacts;
          });
        };

        # --- Developer Shell (`nix develop`) ---
        devShells.default = craneLib.devShell {
          # Inherit build inputs and environment variables from checks
          checks = self.checks.${system};

          # Extra developer tooling inside the shell
          packages = with pkgs; [
            cargo-llvm-cov
            # mini-redis
            # cargo-edit
            # cargo-watch
            # cargo-nextest
          ];

          # Set shell environment variables if needed
          # RUST_BACKTRACE = "1";
        };
      });
}
