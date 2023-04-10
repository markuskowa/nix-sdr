{ lib, stdenv, fetchFromGitHub, cmake, pkg-config,
  boost, mbedtls, fftwFloat, libconfig, lksctp-tools,
  soapysdr-with-plugins, zeromq, pcsclite, limesuite } :

stdenv.mkDerivation rec {
  pname = "srsran";
  version = "unstable-2023-03-23-limesdr";

  src = fetchFromGitHub {
    owner = "herlesupreeth";
    repo = "srsRAN";
    rev = "10f81ca03684efd110557814db17ac2a668342ef";
    sha256 = "sha256-qEimZZe1U9a3NPkTkdBjiiOxSGNVMixrboN0nh/aeJY=";
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
