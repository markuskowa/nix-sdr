{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, talloc, libyaml, mongoc, lksctp-tools, ninja, flex, bison
, libgcrypt, libidn, gnutls, libnghttp2, libmicrohttpd, curl
, libxml2 } :

stdenv.mkDerivation rec {
  pname = "freeDiameter";
  version = "1.5.0";

  src= fetchFromGitHub {
    owner = "freeDiameter";
    repo = "freeDiameter";
    rev = "${version}";
    sha256 = "sha256-hd71wR4b/pnAUcd2U4/InmubCAqkKUZeZTBrGTV3FSY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    flex
    bison
  ];

  buildInputs = [
    lksctp-tools
    gnutls
    libgcrypt
    libidn
    libxml2
  ];

  meta = with lib; {
    description = "Standalone Diameter service";
    homepage = "https://github.com/freeDiameter/freeDiameter";
    license = licenses.bsd3;
  };
}
