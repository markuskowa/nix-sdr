{ lib, stdenv, fetchFromGitHub, meson, pkg-config
, talloc, libyaml, mongoc, mongosh, lksctp-tools, ninja, flex, bison
, libgcrypt, libidn, gnutls, libnghttp2, libmicrohttpd, curl, cmake } :

let
  diameter = fetchFromGitHub {
    owner = "open5gs";
    repo = "freeDiameter";
    rev = "r1.5.0";
    sha256 = "sha256-0sxzQtKBx313+x3TRsmeswAq90Vk5jNA//rOJcEZJTQ=";
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
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "open5gs";
    repo = "open5gs";
    rev = "v${version}";
    sha256 = "sha256-jlWiie7xT1I6F612v49zDfOElJEnOR5GUzFP38TklJk=";
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
  env.NIX_CFLAGS_COMPILE = builtins.toString [
    "-Wno-error=array-bounds"
    "-Wno-error=stringop-overflow"
  ];

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

  postInstall = /* bash */''
    cp misc/db/open5gs-dbctl $out/bin
    substituteInPlace $out/bin/open5gs-dbctl \
      --replace "mongosh" "${lib.getExe mongosh}"
  '';

  meta = with lib; {
    description = "4G/5G core network components";
    homepage = "https://open5gs.org/open5gs/docs";
    license = licenses.agpl3Only;
  };
}
