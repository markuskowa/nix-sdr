{ lib, stdenv, fetchFromGitHub, cmake, pkg-config,
  boost, mbedtls, fftwFloat, libconfig, lksctp-tools,
  soapysdr-with-plugins, zeromq } :

stdenv.mkDerivation rec {
  pname = "srsran";
  version = "22.04";

  src = fetchFromGitHub {
    owner = "srsran";
    repo = "srsRAN";
    rev = "release_22_04";
    sha256 = "sha256-FC6RopxEgZdMTyWvbn7Bwom93hWuDD8lEhqC/GuxhAw=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [
    fftwFloat
    boost
    mbedtls
    libconfig
    lksctp-tools
    soapysdr-with-plugins
    zeromq
  ];
}