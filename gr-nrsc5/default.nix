{ lib
, mkDerivation
, fetchFromGitHub
, fetchpatch
, cmake
, gnuradio
, fdk-aac-hdc
, log4cpp
, mpir
, boost
, python
, libsndfile
, gsl
, gmpxx
} :

mkDerivation rec {
  pname = "gr-nrsc5";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "argilo";
    repo = "gr-nrsc5";
    rev = "v${version}";
    hash = "sha256-+NIYyLPfbZrn9cGpd7avoiNeEoCZ4ne7ngJ+oAS9FpM=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    gnuradio
    fdk-aac-hdc
    log4cpp
    mpir
    boost
    python.pkgs.pybind11
    python.pkgs.numpy
    libsndfile
    gsl
    gmpxx
  ];

  postInstall = ''
    mkdir $out/share/gnuradio/examples
    cp ../apps/* $out/share/gnuradio/examples
  '';

  cmakeFlags = [
    "-DFDK_AAC_LIBRARY=${fdk-aac-hdc}/lib/libfdk-aac.so"
    "-DFDK_AAC_INCLUDE_DIR=${fdk-aac-hdc}/"
  ];
}
