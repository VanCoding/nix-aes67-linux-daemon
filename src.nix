{ fetchFromGitHub }:
rec {
  version = "81db129b2c0022154296201f52dde3d35b7f5af1";
  src = fetchFromGitHub {
    owner = "VanCoding";
    repo = "aes67-linux-daemon";
    rev = version;
    hash = "sha256-pX/bDmz8zZPp+78vRjw0H5OkPbtqfTS0ko1M0+rnCnk=";
    fetchSubmodules = true;
  };
}
