{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, zeromq, boost, curl
} :

let
  version = "3.1.0";

in stdenv.mkDerivation {
  name = "odrDabMux-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-DabMux";
    rev = "v${version}";
    sha256 = "1iv9ivvk0l4y1jfn9933kq0ab0z60yj9ywlyincvgs1frv366lp7";
  };

  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ zeromq boost curl ];

  configureFlags = [
     "--with-boost-system=boost_system"
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

