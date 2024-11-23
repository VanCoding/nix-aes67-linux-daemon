{
  lib,
  config,
  dream2nix,
  src,
  ...
}:
{
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = "${src.src}/webui";
    preInstallPhases = lib.mkForce [ ];
    installPhase = ''
      mkdir -p $out
        cp -r dist $out/webui
    '';
  };

  nodejs-package-lock-v3 = {
    packageLockFile = "${config.mkDerivation.src}/package-lock.json";
  };

  name = "webui";
  version = src.version;
}
