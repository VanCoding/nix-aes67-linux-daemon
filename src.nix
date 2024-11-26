{ fetchFromGitHub }:
rec {
  version = "d90e7cae20b831461fff046cf989f72371f6acdf";
  src = fetchFromGitHub {
    owner = "bondagit";
    repo = "aes67-linux-daemon";
    rev = version;
    hash = "sha256-m5pq4AhpgH8N2eDCT8eNRwONBvO3XA/4YbY2i3srwss=";
    fetchSubmodules = true;
  };
}
