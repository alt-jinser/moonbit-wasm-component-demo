{
  description = "A startup basic project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";

    moonbit-overlay = {
      url = "github:jetjinser/moonbit-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devshell.flakeModule ];

      perSystem = { pkgs, system, ... }:
        let
          wac = pkgs.callPackage ./wac.nix { };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.moonbit-overlay.overlays.default
              (import inputs.rust-overlay)
            ];
          };

          packages.wac = wac;

          devshells.default = {
            packages = with pkgs; [
              moonbit-bin.moonbit.latest
              moonbit-bin.lsp.latest
              (pkgs.rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" "rust-analyzer" ];
                targets = [ "wasm32-wasip1" ];
              })
              cargo-component
              gcc

              gnumake
              checkmake

              wasmtime
              wasm-tools
              wit-bindgen
              wac
            ];
          };
        };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    };
}
