{ lib, stdenv, fetchFromGitHub, cmake, pkg-config,
  boost, mbedtls, fftwFloat, libconfig, lksctp-tools,
  soapysdr-with-plugins, zeromq, pcsclite, limesuite } :

stdenv.mkDerivation rec {
  pname = "srsran";
  version = "unstable-2022-12-20-limesdr";

  src = fetchFromGitHub {
    owner = "herlesupreeth";
    repo = "srsRAN";
    rev = "b07aa314608bbb45ae4080f9e53f6fbeeda6d992";
    sha256 = "sha256-ftAFFLO/j9A48MnnfygltfxCuz5cRnnUW+S+WTyF0q8=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  cmakeFlags = [ "-DUSE_LTE_RATES=ON" ];

  LIMESUITE_DIR="${limesuite}";

  buildInputs = [
    fftwFloat
    boost
    mbedtls
    libconfig
    lksctp-tools
    pcsclite
    # soapysdr-with-plugins
    zeromq
    limesuite
  ];

  meta = with lib; {
    description = "4G/5G software radio suite";
    homepage = "https://docs.srsran.com/en/latest/";
    license = with licenses; [ lgpl21Only mit bsd3 agpl3Plus ];
  };
}
