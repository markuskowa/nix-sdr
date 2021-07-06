{ stdenv, fetchFromGitHub, cmake
, libgpiod, mosquitto
} :

let
  inih = stdenv.mkDerivation rec {
    pname = "inih";
    version = "2019-10-13";

    src = fetchFromGitHub {
      owner = "jtilly";
      repo = "inih";
      rev = "1185eac0f0977654f9ac804055702e110bb4da91";
      sha256 = "1113nhwhph0bjb908adzmrv5gbx0j9nzz1mzix76vd1f0mlmh7y1";
    };

    installPhase = ''
      mkdir -p $out/include
      install INIReader.h $out/include
    '';
  };

in stdenv.mkDerivation rec {
  pname = "nexus433";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "aquaticus";
    repo = "nexus433";
    rev = "v${version}";
    sha256 = "0appl2mxjl330xzg0y3kj29p44yk5qyc9zmq8adnv6wpwwd24iim";
  };


  postPatch = ''
    substituteInPlace version.cmake --replace \
       ' ''${GIT_VERSION}' ' ${version}'

    substituteInPlace CMakeLists.txt --replace \
       '/etc' "$out/etc"

  '';

  buildInputs = [ libgpiod mosquitto ];

  nativeBuildInputs = [ cmake ];
}
