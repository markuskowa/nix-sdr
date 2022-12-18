{ lib, stdenv, fetchFromGitHub, cmake, pkg-config,
  boost, mbedtls, fftwFloat, libconfig, lksctp-tools,
  soapysdr-with-plugins, zeromq, pcsclite } :

stdenv.mkDerivation rec {
  pname = "srsran";
  version = "22.10";

  src = fetchFromGitHub {
    owner = "srsran";
    repo = "srsRAN";
    rev = "release_${lib.replaceChars ["."] ["_"] version}";
    sha256 = "sha256-O43MXJ6EyKXg7hA1WjW8TqLmAWC+h5RLBGzBO6f/0zo=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  cmakeFlags = [ "-DUSE_LTE_RATES=ON" ];

  buildInputs = [
    fftwFloat
    boost
    mbedtls
    libconfig
    lksctp-tools
    pcsclite
    soapysdr-with-plugins
    zeromq
  ];

  meta = with lib; {
    description = "4G/5G software radio suite";
    homepage = "https://docs.srsran.com/en/latest/";
    license = with licenses; [ lgpl21Only mit bsd3 agpl3Plus ];
  };
}
