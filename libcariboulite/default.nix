{ lib, stdenv, fetchFromGitHub, cmake, soapysdr, zeromq } :

stdenv.mkDerivation {
  pname = "libcariboulite";
  version = "2023-01-20-unstable";

  src = fetchFromGitHub {
    owner = "cariboulabs";
    repo = "cariboulite";
    rev = "554c39e589ef7b7857ad674fb49ab4d6395cf940";
    sha256 = "sha256-iIcKQTvH9NpPHOkb/b+BNN/4v3A6HjQDFTtUuJ2JRd8=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace software/libcariboulite/CMakeLists.txt \
      --replace "/usr/local/lib" "$out/lib"

  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ soapysdr zeromq ];

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
