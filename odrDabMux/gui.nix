{ lib, stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, boost, curl, python3
} :

let
  version = "4.1.0";
  python = python3.withPackages (ps: with ps; [ pyzmq cherrypy jinja2 ]);

in stdenv.mkDerivation {
  name = "odrDabMux-gui-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMux";
    rev = "v${version}";
    sha256 = "0293qgjh6qfwi24map106079fp9c77bgr0z9hlhrsjxsn4addx1n";
  };

  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ python ];

  postPatch = ''
#sed -i 's/mux_port=12720/mux_port=12722/' gui/muxconfig.py
    substituteInPlace ./gui/odr-dabmux-gui.py --replace \
      "rcparam.json" "$out/bin/rcparam.json"
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp -r gui/* $out/bin
  '';

  meta = with lib; {
    description = "DAB/DAB+ multiplexer";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
