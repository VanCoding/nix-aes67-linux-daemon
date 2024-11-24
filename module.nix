flake:
{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aes67-daemon;
in
{
  options.aes67-daemon = {
    package = lib.mkOption {
      type = lib.types.package;
      default = flake.packages.${pkgs.system}.default;
    };
    config = lib.mkOption {
      type = lib.types.submodule {
        freeformType = (pkgs.formats.json { }).type;
      };
      default = {
        "http_base_dir" = "${cfg.package}/webui/";
        "ptp_status_script" = "${cfg.package}/scripts/ptp_status.sh";
      };
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      default = pkgs.writeText "daemon.conf" (builtins.toJSON cfg.config);
    };

    start = lib.mkOption {
      type = lib.types.package;
      description = "Script to start the daemon";
      default = pkgs.writeShellApplication {
        name = "start-aes67-daemon";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.nodejs
        ];
        text = ''
          if [ ! -f ./daemon.conf ]; then
            cat ${./default-config.json} > ./daemon.conf
          fi
          node --eval "require('fs').writeFileSync('./daemon.conf',JSON.stringify({\
            ...JSON.parse(require('fs').readFileSync('./daemon.conf')+'''),\
            ...JSON.parse(require('fs').readFileSync('${cfg.configFile}')+''')\
          },null,2))"
          ${cfg.package}/bin/aes67-daemon --config ./daemon.conf
        '';
      };
    };
  };
  config =
    if builtins.hasAttr "boot" options then
      {
        boot.extraModulePackages = [
          (config.boot.kernelPackages.callPackage ./kernel-module.nix { })
        ];
        boot.kernelModules = [
          "MergingRavennaALSA"
        ];
        systemd.services.aes67-daemon = {
          enable = true;
          after = [ "network.target" ];
          wantedBy = [ "default.target" ];
          serviceConfig = {
            ExecStart = "${cfg.start}/bin/start-aes67-daemon";
            User = "aes67-daemon";
            StateDirectory = "aes67-daemon";
            WorkingDirectory = "/var/lib/aes67-daemon";
          };
        };
        users.users.aes67-daemon = {
          isSystemUser = true;
          group = "aes67-daemon";
        };
        users.groups.aes67-daemon = { };

        services.avahi = {
          enable = true;
          publish = {
            enable = true;
            userServices = true;
          };
        };
      }
    else
      { };
}
