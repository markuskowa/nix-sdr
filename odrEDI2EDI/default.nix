{ lib, stdenv, fetchFromGitHub, autoconf, automake, libtool }:

stdenv.mkDerivation rec {
  pname = "odr-edi2edi";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = pname;
    rev = "v${version}";
    sha256 = "02j9bkabvch6jdmxaiyj17gpd07gjcarix2hpw0apglv7zk7z56n";
  };

  nativeBuildInputs = [ autoconf automake libtool ];

  preConfigure = ''
    ./bootstrap.sh
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "DAB stream converter";
    homepage = "https://github.com/Opendigitalradio/ODR-EDI2EDI/";
    license = licenses.mit;
    maintainers = with maintainers; [ markuskowa ];
  };
}
