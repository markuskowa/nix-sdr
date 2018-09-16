{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, boost, curl
} :

let
  version = "2.2.0";

in stdenv.mkDerivation {
  name = "odrAudioEnc-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMux";
    rev = "v${version}";
    sha256 = "0qmnp8cs7lryqwgn4y91gbcg1aq928x9pf1alaxgm6vffps1236p";
  };

  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ zeromq boost curl ];

  configureFlags = [
    "--with-boost-thread=boost_thread"
  ];

  preConfigure = ''
    ./bootstrap.sh
  '';

  postInstall = ''
    mkdir -p $out/share/man/man1
    mkdir -p $out/share/doc

    cp doc/DabMux.1 $out/share/man/man1
    cp doc/* $out/share/doc
  '';

  enableParalleBuilding = true;

  meta = with stdenv.lib; {
    description = "DAB/DAB+ multiplexer";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}

