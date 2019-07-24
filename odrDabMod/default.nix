{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, fftwFloat, uhd, boost, soapysdr-with-plugins
} :

let
  version = "2.3.1";

in stdenv.mkDerivation {
  name = "odrDabMod-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMod";
    rev = "v${version}";
    sha256 = "1j98mgj009b3v8p9nl7h0dzj2pyxh9iyng0rni203a4xrc3b6xrd";
  };

  nativeBuildInputs = [ autoconf automake libtool pkgconfig ];
  buildInputs = [ zeromq fftwFloat uhd boost soapysdr-with-plugins ];

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

