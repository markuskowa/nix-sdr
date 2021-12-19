{ stdenv, lib, fetchFromGitHub, autoconf, automake, libtool
, pkg-config, zeromq, fftwFloat, uhd, boost, soapysdr-with-plugins
} :

let
  version = "2.4.2";

in stdenv.mkDerivation {
  pname = "odrDabMod";
  inherit version;

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMod";
    rev = "v${version}";
    sha256 = "1ijqgpyp4afjj5w1nwyzwkvllhijy5nipaf3zhj76h9ck9qzb419";
  };

  nativeBuildInputs = [ autoconf automake libtool pkg-config boost ];
  buildInputs = [ zeromq fftwFloat uhd boost soapysdr-with-plugins ];

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
