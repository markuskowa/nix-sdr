{ lib, stdenv, fetchFromGitHub, systemd } :

stdenv.mkDerivation rec {
  pname = "rtpproxy";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "sippy";
    repo = "rtpproxy";
    rev = "v${version}";
    sha256 = "sha256-+XZMntrvivvkDf5ZmzQCdGsiRUZMOC9B/iLBVQ+xbMw=";
    fetchSubmodules = true;
  };

  buildInputs = [ systemd ];

  meta = with lib; {
    description = "Software proxy for RTP streams that can work together with OpenSIPS, Kamailio or Sippy B2BUA";
    homepage = "http://rtpproxy.org";
    license = licenses.bsd2;
  };
}
