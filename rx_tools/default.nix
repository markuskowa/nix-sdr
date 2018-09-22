{ stdenv, fetchFromGitHub, soapysdr-with-plugins, cmake } :

let
  version = "1.0.3";
in

stdenv.mkDerivation {
  name = "rxtools-${version}";

  src = fetchFromGitHub {
    owner = "rxseger";
    repo = "rx_tools";
    rev = "b6ca2a8c3a423a122ac398ddd5875fccbc9d6b33";
    sha256 = "00626a6h2n44qcmc9sj6gg9jiirnk5vqs3jrl84fnslnphp001di";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ soapysdr-with-plugins ];

  meta = {
    homepage = https://github.com/rxseger/rx_tools;
    description = "RTLSDR tools with SoapySDR backend";
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.unix;
  };

  
}
