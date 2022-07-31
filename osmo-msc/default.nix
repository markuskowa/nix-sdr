{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif, libosmo-sccp
, osmo-mgw, osmo-hlr, lksctp-tools
, sqlite
}:


stdenv.mkDerivation rec {
  pname = "osmo-msc";
  version = "1.9.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-msc";
    rev = version;
    sha256 = "sha256-XxVFg2bmLKGLKxivkVy1/xJairjOhaKSQlFHn9cSjaw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libosmocore
    libosmo-abis
    libosmo-netif
    libosmo-sccp
    osmo-mgw
    osmo-hlr
    lksctp-tools
    sqlite
  ];
}
