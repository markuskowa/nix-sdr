{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif, libosmo-sccp
, osmo-mgw, sqlite
}:


stdenv.mkDerivation rec {
  pname = "osmo-bsc";
  version = "1.9.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-bsc";
    rev = version;
    sha256 = "sha256-RxkyJ7XP16jIHdkTH0i8N6UREemJHx6fv6xX9sFyldg=";
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
    sqlite
  ];
}
