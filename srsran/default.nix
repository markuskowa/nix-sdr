{ lib, stdenv, fetchFromGitHub, cmake, pkg-config,
  boost, mbedtls, fftwFloat, libconfig, lksctp-tools,
  soapysdr-with-plugins, zeromq, pcsclite } :

stdenv.mkDerivation rec {
  pname = "srsran";
  version = "22.04.1";

  src = fetchFromGitHub {
    owner = "srsran";
    repo = "srsRAN";
    rev = "release_${lib.replaceChars ["."] ["_"] version}";
    sha256 = "sha256-jqaGlMhy6L6lRknl6Ezi0n+vNjMb7C+FN9a+QeOy/RY=";
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
