{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, fftwFloat, uhd, boost
} :

let
  version = "2.2.0";

in stdenv.mkDerivation {
  name = "odrDabMod-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMod";
    rev = "v${version}";
    sha256 = "01ralq8lzzmkxw1j8xclpvx2h6y43v1xws61pfc8yxf7scszadqr";
  };

  nativeBuildInputs = [ autoconf automake libtool pkgconfig ];
  buildInputs = [ zeromq fftwFloat uhd boost ];

  configureFlags = [
    "--enable-fast-math"
    "--enable-edi"
  ];

  preConfigure = ''
    ./bootstrap.sh
  '';

  postInstall = ''
    mkdir -p $out/share/doc/odrDabMod

    cp -r doc/* $out/share/doc/odrDabMod
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "DAB/DAB+ modulator";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.markuskowa ];
  };
}

