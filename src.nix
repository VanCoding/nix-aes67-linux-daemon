{ fetchFromGitHub }:
rec {
  version = "6563a56da463b458202ee72ed518572c116537f1";
  src = fetchFromGitHub {
    owner = "bondagit";
    repo = "aes67-linux-daemon";
    rev = version;
    name = version;
    hash = "sha256-0Xg0WHaoVaJ3kFN78hbpYjbm/0On+eRKlPhRaUWZ71w=";
    fetchSubmodules = true;
  };
}
