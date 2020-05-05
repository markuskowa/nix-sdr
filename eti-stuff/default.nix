{ stdenv, fetchFromGitHub, cmake, pkg-config
, fftwFloat, libsndfile, libsamplerate
, rtl-sdr, airspy
, device ? "rtl-sdr"
} :

let
  version = "20190623";

in stdenv.mkDerivation {
  name = "eti-stuff-${version}";

  src = fetchFromGitHub {
    owner = "JvanKatwijk";
    repo = "eti-stuff";
    rev = "c99ad9e5c2d5fbe3988378f87c90a1f8bda64d79";
    sha256 = "0rbi3fahgikqf3732lvhqvvxfgnwg071yxh36lwpzdc67fwqgq4k";
  };

  preConfigure = ''
    cd eti-cmdline
  '';

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ fftwFloat libsndfile libsamplerate rtl-sdr airspy ];

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

