flake:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.aes67-linux-daemon = {
    enable = lib.mkEnableOption "Enable aes67-linux-daemon";
    data-dir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/aes67-linux-daemon";
      description = "Data directory for aes67-linux-daemon";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = flake.packages.${pkgs.system}.default;
    };

    config = lib.mkOption {
      type = lib.types.submodule {
        freeformType = (pkgs.formats.json { }).type;
      };
      default = {
        "http_base_dir" = "${config.aes67-linux-daemon.package}/webui/";
        "ptp_status_script" = "${config.aes67-linux-daemon.package}/scripts/ptp_status.sh";
      };
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      default = pkgs.writeText "daemon.conf" (builtins.toJSON config.aes67-linux-daemon.config);
    };

    start = lib.mkOption {
      type = lib.types.package;
      description = "Script to start the daemon";
      default = pkgs.writeShellApplication {
        name = "start-aes67-linux-daemon";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.nodejs
        ];
        text = ''
          if [ ! -f ./daemon.conf ]; then
            cp ${./default-config.json} ./daemon.conf
          fi
          node --eval "require('fs').writeFileSync('./daemon.conf',JSON.stringify({\
            ...JSON.parse(require('fs').readFileSync('./daemon.conf')+'''),\
            ...JSON.parse(require('fs').readFileSync('${config.aes67-linux-daemon.configFile}')+''')\
          },null,2))"
          ${config.aes67-linux-daemon.package}/bin/aes67-daemon --config ./daemon.conf
        '';
      };
    };
  };
}
