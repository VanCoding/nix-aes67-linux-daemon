{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    dream2nix.url = "github:nix-community/dream2nix";
  };
  outputs =
    inputs@{ self, dream2nix, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {

      flake.nixosModules.default = import ./module.nix self;

      systems = [ "x86_64-linux" ];
      perSystem =
        {
          pkgs,
          system,
          lib,
          ...
        }:
        {
          _module.args.pkgs = import self.inputs.nixpkgs {
            inherit system;
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "faac"
              ];
          };
          devShells.default = pkgs.mkShell {
            buildInputs = [ pkgs.nixfmt-rfc-style ];
          };

          packages =
            let
              src = pkgs.callPackage ./src.nix { };
            in
            rec {
              daemon = pkgs.callPackage ./daemon.nix { inherit src; };
              tests = pkgs.callPackage ./tests.nix { inherit src; };
              webui = dream2nix.lib.evalModules {
                packageSets.nixpkgs = pkgs;
                modules = [
                  ./webui.nix
                ];
                specialArgs = {
                  inherit src;
                };
              };
              default = pkgs.symlinkJoin {
                name = "aes67-linux-daemon";
                paths = [
                  daemon
                  tests
                  webui
                ];
              };
              test =
                (lib.evalModules {
                  modules = [
                    self.nixosModules.default
                  ];
                  specialArgs = {
                    inherit pkgs;
                  };
                }).config.aes67-linux-daemon.start;
            };
        };
    };
}
