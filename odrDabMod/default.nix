{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, fftwFloat, uhd, boost, soapysdr-with-plugins
} :

let
  version = "2.4.1";

in stdenv.mkDerivation {
  name = "odrDabMod-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMod";
    rev = "v${version}";
    sha256 = "1qa8n59mdbfysg1s653dwy72ca0sk7m11q9b65nsrhha1px31cqd";
  };

  nativeBuildInputs = [ autoconf automake libtool pkgconfig boost ];
  buildInputs = [ zeromq fftwFloat uhd boost soapysdr-with-plugins ];

  CFLAGS="-O3 -DNDEBUG";
  CXXFLAGS="-O3 -DNDEBUG";

  configureFlags = [
    "--enable-fast-math"
    "--enable-limesdr"
    "--enable-edi"
    "--with-boost-thread=boost_thread"
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

