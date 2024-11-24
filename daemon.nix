{
  stdenv,
  cmake,
  boost,
  avahi,
  alsa-lib,
  systemd,
  faac,
  callPackage,
}:
let
  src = callPackage ./src.nix { };
in
stdenv.mkDerivation {
  pname = "aes67-linux-daemon";
  version = src.version;
  src = src.src;
  buildInputs = [
    cmake
    boost.dev
    avahi.dev
    alsa-lib.dev
    systemd.dev
    faac
  ];
  configurePhase = ''
    cd daemon
    cmake \
      -DCPP_HTTPLIB_DIR="$src/3rdparty/cpp-httplib" \
      -DRAVENNA_ALSA_LKM_DIR="$src/3rdparty/ravenna-alsa-lkm" \
      -DENABLE_TESTS=ON \
      -DWITH_AVAHI=ON \
      -DFAKE_DRIVER=OFF \
      -DWITH_SYSTEMD=ON \
      -DWITH_STREAMER=ON \
      .
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp aes67-daemon $out/bin
    cp -r scripts $out
  '';
}
