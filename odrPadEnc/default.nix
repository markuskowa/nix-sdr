{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, imagemagick
} :

let
  version = "3.0.0";

in stdenv.mkDerivation {
  name = "odrPadEnc-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-PadEnc";
    rev = "v${version}";
    sha256 = "1m5ak9akpkqhivw1mnhcg3l4hnxg5fap3hncbvwg1k1rqxly9byr";
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
    maintainers = [ maintainers.markuskowa ];
  };
}
