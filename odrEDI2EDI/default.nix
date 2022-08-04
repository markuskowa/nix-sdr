{ lib, stdenv, fetchFromGitHub, autoconf, automake, libtool, zeromq }:

stdenv.mkDerivation rec {
  pname = "odr-edi2edi";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-CU/Bu/P3o1c8qccDAvESeG+sDoCVZOsOWRrzc7FGif8=";
  };

  nativeBuildInputs = [ autoconf automake libtool ];

  preConfigure = ''
    ./bootstrap.sh
  '';

  buildInputs = [ zeromq ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "DAB stream converter";
    homepage = "https://github.com/Opendigitalradio/ODR-EDI2EDI/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ markuskowa ];
  };
}
