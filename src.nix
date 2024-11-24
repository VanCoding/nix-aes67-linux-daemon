{ fetchFromGitHub }:
rec {
  version = "3f017f8d5d606489c32c2789480ba626586e9d55";
  src = fetchFromGitHub {
    owner = "VanCoding";
    repo = "aes67-linux-daemon";
    rev = version;
    hash = "sha256-iQYOs6msP1buB1pDmsdOvUNp+Zhlgoe33nGGA7ZuOoA=";
    fetchSubmodules = true;
  };
}
