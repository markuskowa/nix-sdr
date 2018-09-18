{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, imagemagick
} :

let
  version = "2.3.0";

in stdenv.mkDerivation {
  name = "odrPadEnc-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-PadEnc";
    rev = "v${version}";
    sha256 = "04sdhzd393z4k1k7756dm4612nqnrx52jllkxgvhw4px4hddqwrg";
  };

  nativeBuildInputs = [ autoconf automake libtool pkgconfig ];
  buildInputs = [ imagemagick ];

  preConfigure = ''
    ./bootstrap
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "DAB/DAB+ PAD encode";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
