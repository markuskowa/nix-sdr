{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, zeromq, boost, curl
} :

let
  version = "2.2.0";

in stdenv.mkDerivation {
  name = "odrDabMux-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMux";
    rev = "v${version}";
    sha256 = "0qmnp8cs7lryqwgn4y91gbcg1aq928x9pf1alaxgm6vffps1236p";
  };

  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ zeromq boost curl soapysdr-with-plugins ];

  configureFlags = [
    "--with-boost-thread=boost_thread"
  ];

  preConfigure = ''
    ./bootstrap.sh
  '';

  postInstall = ''
    mkdir -p $out/share/man/man1
    mkdir -p $out/share/doc/odrDabMux

    cp doc/DabMux.1 $out/share/man/man1
    cp doc/* $out/share/doc/odrDabMux
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "DAB/DAB+ multiplexer";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = licenses.gpl3;
    maintainers = maintainers.markuskowa;
    platforms = platforms.linux;
  };
}

