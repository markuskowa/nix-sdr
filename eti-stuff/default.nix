{ stdenv, lib, fetchFromGitHub, cmake, pkg-config
, fftwFloat, libsndfile, libsamplerate
, rtl-sdr, airspy, libusb1
, device ? "rtl-sdr"
} :

let
  version = "20220621";

in stdenv.mkDerivation {
  name = "eti-stuff-${version}";

  src = fetchFromGitHub {
    owner = "JvanKatwijk";
    repo = "eti-stuff";
    rev = "812095bbd7627d30359476d022ed1cae2a6b0efb";
    sha256 = "sha256-wCJnYOnb1BwnoEZ1YdFC4YYTCyoj8SYTAbxp14F/Vg0=";
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

  meta = with lib; {
    description = "";
    homepage = "https://";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}

