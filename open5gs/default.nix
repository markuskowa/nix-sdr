{ lib, stdenv, fetchFromGitHub, meson, pkg-config
, talloc, libyaml, mongoc, lksctp-tools, ninja, flex, bison
, libgcrypt, libidn, gnutls, libnghttp2, libmicrohttpd, curl, cmake } :

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

  promc = fetchFromGitHub {
    owner = "open5gs";
    repo = "prometheus-client-c";
    rev = "a58ba25bf87a9b1b7c6be4e6f4c62047d620f402"; # open5gs branch
    sha256 = "sha256-COZV4UeB7YRfpLwloIfc/WdlTP9huwVfXrJWH4jmvB8=";
  };

in stdenv.mkDerivation rec {
  pname = "open5gs";
  version = "2.5.8";

  src = fetchFromGitHub {
    owner = "open5gs";
    repo = "open5gs";
    rev = "v${version}";
    sha256 = "sha256-qpbB4yhCrRRipuU44Tfna9eJnlJO9Cs3B2gx6Xpp8Y8=";
  };

  postPatch = ''
    cp -R --no-preserve=mode,ownership ${diameter} subprojects/freeDiameter
    cp -R --no-preserve=mode,ownership ${libtins} subprojects/libtins
    cp -R --no-preserve=mode,ownership ${promc} subprojects/prometheus-client-c
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
    cmake
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
