{ stdenv, lib, fetchFromGitHub, autoconf, automake, libtool
, zeromq, boost, curl, python3
} :

let
  version = "4.5.0";

  python = python3.withPackages (ps: with ps; [ pyzmq ]);

in stdenv.mkDerivation {
  name = "odrDabMux-${version}";
  inherit version;

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMux";
    rev = "v${version}";
    sha256 = "sha256-AL0482ow0HOUqnH0pIJbVcbDHy3j+AXMhsjpVEKKIbU=";
  };

  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ zeromq boost curl python ];

  configureFlags = [
     "--with-boost-system=boost_system"
  ];

  preConfigure = ''
    ./bootstrap.sh
  '';

  postInstall = ''
    mkdir -p $out/share/man/man1
    mkdir -p $out/share/doc/odrDabMux

    install -m755 doc/show_dabmux_stats.py $out/bin

    cp doc/* $out/share/doc/odrDabMux
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "DAB/DAB+ multiplexer";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = licenses.gpl3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

