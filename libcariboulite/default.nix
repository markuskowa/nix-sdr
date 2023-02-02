{ lib, stdenv, fetchFromGitHub, cmake, soapysdr } :

stdenv.mkDerivation {
  pname = "libcariboulite";
  version = "2023-01-20-unstable";

  src = fetchFromGitHub {
    owner = "cariboulabs";
    repo = "cariboulite";
    rev = "b9997023341d56698fcf4e693005413a833ee214";
    sha256 = "sha256-vYWYexLiuVP+6qKX2x0GhPhVDR62MF6S36MtoasvCcU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ soapysdr ];

  hardeningDisable = [ "format" ];

  preConfigure = ''
    cd software/libcariboulite
  '';

  postInstall = ''
    mkdir -p $out/bin

    cp cariboulite_* $out/bin
    make -C src/iir install
  '';

  preFixup = ''
    # Clear rpath to avoid refs to /build/
    patchelf --set-rpath $(patchelf --print-rpath $out/bin/cariboulite_app | sed 's|.*/build/src/iir:||') $out/bin/cariboulite_app
    patchelf --set-rpath $(patchelf --print-rpath $out/bin/cariboulite_prod | sed 's|.*/build/src/iir:||') $out/bin/cariboulite_prod
  '';

  meta = with lib; {
    description = "Drivers for the CaribouLite SDR";
    homepage = "https://github.com/cariboulabs/cariboulite";
    license = licenses.cc-by-sa-40;
  };
}
