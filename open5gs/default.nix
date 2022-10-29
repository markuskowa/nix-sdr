{ lib, stdenv, fetchFromGitHub, meson, pkg-config
, talloc, libyaml, mongoc, lksctp-tools, ninja, flex, bison
, libgcrypt, libidn, gnutls, libnghttp2, libmicrohttpd, curl } :

let
  diameter = fetchFromGitHub {
    owner = "open5gs";
    repo = "freeDiameter";
    rev = "r1.5.0";
    sha256 = "sha256-dqdBy/kFZW9EvwX4zdwpb3ZGYcSjfH9FqvSHDaasdR4=";
  };

  libtins = fetchFromGitHub {
    owner = "open5gs";
    repo = "libtins";
    rev = "r4.3";
    sha256 = "sha256-q++F1bvf739P82VpUf4TUygHjhYwOsaQzStJv8PN2Hc=";
  };

in stdenv.mkDerivation rec {
  pname = "open5gs";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "open5gs";
    repo = "open5gs";
    rev = "v${version}";
    sha256 = "sha256-+HBHWaC7RN23VcSDXBUy1gOIKc9yWqCj4Q++YjRb+Ig=";
  };

  postPatch = ''
    cp -R --no-preserve=mode,ownership ${diameter} subprojects/freeDiameter
    cp -R --no-preserve=mode,ownership ${libtins} subprojects/libtins
  '';

  nativeBuildInputs = [
    ninja
    meson
    pkg-config
    flex
    bison
  ];

  mesonFlags = [ "-Dwerror=false" "--buildtype=release"];

  # Fails in libtins (DHCPv6)
  NIX_CFLAGS_COMPILE = "-Wno-error=array-bounds";

  buildInputs = [
    talloc
    libyaml
    mongoc
    lksctp-tools
    libgcrypt
    libidn
    gnutls
    libnghttp2.dev
    libmicrohttpd
    curl
  ];

  postInstall = ''
    cp misc/db/open5gs-dbctl $out/bin
  '';

  meta = with lib; {
    description = "4G/5G core network components";
    homepage = "https://open5gs.org/open5gs/docs";
    license = licenses.agpl3Only;
  };
}
