{ lib, stdenv, fetchFromGitHub, cmake
, spdlog, rtl-sdr, nlohmann_json, gtest, boost
, fftw, fftwFloat, liquid-dsp, mosquitto, hackrf
}:

stdenv.mkDerivation rec {
  pname = "rtl-sdr-scanner-cpp";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "shajen";
    repo = "rtl-sdr-scanner-cpp";
    rev = "v${version}";
    sha256 = "sha256-K6u27Xbr71Vf7Sdg0fzTvIukwq/IziKtzGOGGFiHuAU=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    spdlog
    rtl-sdr
    nlohmann_json
    gtest
    boost
    fftw
    fftwFloat
    liquid-dsp
    mosquitto
    hackrf
  ];

  doInstallCheck = true;
  installCheckPhase = "$out/bin/auto_sdr_test";

  meta = with lib; {
    description = "SDR scanner that can monitor multiple frequencies";
    homepage = "https://github.com/shajen/rtl-sdr-scanner-cpp";
    license = licenses.gpl3Only;
  };
}
