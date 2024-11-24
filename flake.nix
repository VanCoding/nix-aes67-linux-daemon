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
      flake.nixosConfigurations.test = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.default
          (
            { pkgs, ... }:
            {
              services.mingetty.autologinUser = "root";
              console.keyMap = "de_CH-latin1";
            }
          )
        ];
      };
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

          packages = rec {
            daemon = pkgs.callPackage ./daemon.nix { };
            tests = pkgs.callPackage ./tests.nix { };
            webui = dream2nix.lib.evalModules {
              packageSets.nixpkgs = pkgs;
              modules = [
                ./webui.nix
              ];
            };
            default = pkgs.symlinkJoin {
              name = "aes67-linux-daemon";
              paths = [
                daemon
                tests
                webui
              ];
            };
            start =
              (lib.evalModules {
                modules = [
                  self.nixosModules.default
                ];
                specialArgs = {
                  inherit pkgs;
                };
              }).config.aes67-daemon.start;
            start-vm = self.nixosConfigurations.test.config.system.build.vm;
          };
        };
    };
}
