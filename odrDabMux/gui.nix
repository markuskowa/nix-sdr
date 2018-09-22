{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, boost, curl, python27
} :

let
  version = "2.2.0";
  python = python27.withPackages (ps: with ps; [ pyzmq ]);

in stdenv.mkDerivation {
  name = "odrDabMux-gui-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMux";
    rev = "v${version}";
    sha256 = "0qmnp8cs7lryqwgn4y91gbcg1aq928x9pf1alaxgm6vffps1236p";
  };

  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ python ];

  postPatch = ''
    sed -i 's/mux_port=12720/mux_port=12722/' gui/muxconfig.py
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp -r gui/* $out/bin
  '';

  meta = with stdenv.lib; {
    description = "DAB/DAB+ multiplexer";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
