{
  stdenv,
  cmake,
  boost,
  avahi,
  alsa-lib,
  callPackage,
}:
let
  src = callPackage ./src.nix { };
in
stdenv.mkDerivation {
  pname = "aes67-linux-daemon-tests";
  version = src.version;
  src = src.src;
  buildInputs = [
    cmake
    boost.dev
    avahi.dev
    alsa-lib.dev
  ];
  configurePhase = ''
    cd daemon/tests
    cmake \
      -DCPP_HTTPLIB_DIR="$src/3rdparty/cpp-httplib" \
      -DRAVENNA_ALSA_LKM_DIR="$src/3rdparty/ravenna-alsa-lkm" \
      -DWITH_AVAHI=ON \
      .
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp daemon-test $out/bin
  '';
}
