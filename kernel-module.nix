{
  stdenv,
  lib,
  kernel,
  kmod,
  callPackage,
}:
let
  src = callPackage ./src.nix { };
in
stdenv.mkDerivation {
  pname = "MergingRavennaALSA";
  version = src.version;

  src = src.src;

  prePatch = ''
    ls -l
    cd 3rdparty/ravenna-alsa-lkm/driver
  '';
  hardeningDisable = [
    "pic"
    "format"
  ]; # 1
  nativeBuildInputs = kernel.moduleBuildDependencies; # 2

  makeFlags = [
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" # 4
  ];

  installPhase = ''
    make $makeFlags INSTALL_MOD_PATH="$out" modules_install
  '';

  meta = {
    description = "A kernel module to create V4L2 loopback devices";
    homepage = "https://github.com/aramg/droidcam";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.makefu ];
    platforms = lib.platforms.linux;
  };
}
