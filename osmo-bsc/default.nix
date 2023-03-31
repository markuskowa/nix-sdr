{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif, libosmo-sccp
, osmo-mgw, sqlite
}:


stdenv.mkDerivation rec {
  pname = "osmo-bsc";
  version = "1.10.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-bsc";
    rev = version;
    sha256 = "sha256-OAYvelHaGzQxUgViqH4PW6SQfCQzPUqxVhr6qTq0y7M=";
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

  meta = with lib; {
    description = "GSM Base Station Controller";
    homepage = "https://osmocom.org/projects/osmobsc/wiki";
    license = licenses.agpl3Only;
  };
}
