{ stdenv, lib, fetchFromGitHub, autoconf, automake, libtool
, pkg-config, zeromq, fftwFloat, uhd, boost
, soapysdr-with-plugins, limesuite
} :

let
  version = "2.6.0";

in stdenv.mkDerivation {
  pname = "odrDabMod";
  inherit version;

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMod";
    rev = "v${version}";
    sha256 = "sha256-zcp3DHRMUHZF414cndiE9DLzGlnwIgv4+56ughml0VU=";
  };

  nativeBuildInputs = [ autoconf automake libtool pkg-config boost ];
  buildInputs = [
    zeromq
    fftwFloat
    boost
    uhd
    limesuite
    soapysdr-with-plugins
  ];

  CFLAGS="-O3 -DNDEBUG";
  CXXFLAGS="-O3 -DNDEBUG";

  configureFlags = [
    "--enable-fast-math"
    "--enable-limesdr"
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

  meta = with lib; {
    description = "DAB/DAB+ modulator";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.markuskowa ];
  };
}
