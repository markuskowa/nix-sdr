{ lib, stdenv, fetchFromGitHub, systemd } :

stdenv.mkDerivation rec {
  pname = "rtpproxy";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "sippy";
    repo = "rtpproxy";
    rev = "v${version}";
    sha256 = "sha256-yQKlGBd7X3tXcz7oU+fBKBudNOp8nIvntpdEzpPLRoo=";
    fetchSubmodules = true;
  };

  buildInputs = [ systemd ];

  meta = with lib; {
    description = "Software proxy for RTP streams that can work together with OpenSIPS, Kamailio or Sippy B2BUA";
    homepage = "http://rtpproxy.org";
    license = licenses.bsd2;
  };
}
