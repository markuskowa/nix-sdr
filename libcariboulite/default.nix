{ lib, stdenv, fetchFromGitHub, cmake, soapysdr, zeromq } :

stdenv.mkDerivation {
  pname = "libcariboulite";
  version = "2023-02-13-R1";

  src = fetchFromGitHub {
    owner = "cariboulabs";
    repo = "cariboulite";
    rev = "4f7d58a95e7f5a0494a94d3faaf980d9e80359a9";
    sha256 = "sha256-y0pYA4il8OXKX5XfWWYdubDdumD15yu4Ip6Ln3jmI+0=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace software/libcariboulite/CMakeLists.txt \
      --replace "/usr/local/lib" "$out/lib"

    substituteInPlace software/libcariboulite/CMakeLists.txt \
      --replace ' ''${BIN_DEST}/lib/' " $out/lib" \
      --replace ' ''${BIN_DEST}/bin/' " $out/bin"

    sed -i '/PREFIX ""/d' software/libcariboulite/CMakeLists.txt
    sed -i '/DESTINATION ''${SOAPY_DEST}/d' software/libcariboulite/CMakeLists.txt
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
    patchelf --set-rpath $(patchelf --print-rpath $out/bin/cariboulite_test_app | sed 's|.*/build/.*:||') $out/bin/cariboulite_test_app
    patchelf --set-rpath $(patchelf --print-rpath $out/bin/cariboulite_util | sed 's|.*/build/.*:||') $out/bin/cariboulite_util
  '';

  meta = with lib; {
    description = "Drivers for the CaribouLite SDR";
    homepage = "https://github.com/cariboulabs/cariboulite";
    license = licenses.cc-by-sa-40;
  };
}
