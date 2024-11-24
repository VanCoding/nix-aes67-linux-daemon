# nix-aes67-linux-daemon

A nix-package and NixOS-module for [aes67-linux-daemon](https://github.com/bondagit/aes67-linux-daemon)

## Usage for NixOS

```nix
{

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nix-aes67-linux-daemon = {
            url = "github:VanCoding/nix-aes67-linux-daemon";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs: {nixpkgs, nix-aes67-linux-daemon, ...}: {
        nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            nix-aes67-linux-daemon.nixosModules.default
            {
                aes67-daemon.config.interface_name = "eth0";
            }
          ];
        };
    };
}
```

## Spin up a NixOS VM in which the deamon runs

```
nix run .#start-vm
```
