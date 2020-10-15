{ stdenv, fetchFromGitHub, cmake, pkg-config
, fftwFloat, libsndfile, libsamplerate
, rtl-sdr, airspy, libusb1
, device ? "rtl-sdr"
} :

let
  version = "20200512";

in stdenv.mkDerivation {
  name = "eti-stuff-${version}";

  src = fetchFromGitHub {
    owner = "JvanKatwijk";
    repo = "eti-stuff";
    rev = "770485ca1a6ba477344c049b8a3fe4b8564a69bd";
    sha256 = "1qdpb11s6pj40a6nzsnkdyy9m8iisjw01ncbzrhrp290j28v1pwb";
  };

  preConfigure = ''
    cd eti-cmdline
  '';

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ fftwFloat libsndfile libsamplerate rtl-sdr airspy libusb1 ];

  CFLAGS="-O3";

  cmakeFlags = [ "-DX64_DEFINED=1" (
    if device == "rtl-sdr" then "-DRTLSDR=ON" else
    if device == "rtl-tcp" then "-DRTL_TCP=ON" else
    if device == "airspy" then "-DAIRSPY=ON" else
    if device == "rawfiles" then "-DRAWFILES=ON" else ""
  ) ];

  postInstall = ''
    mkdir -p $out/bin
    mv $out/eti-* $out/bin
  '';

  meta = with stdenv.lib; {
    description = "";
    homepage = "https://";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}

