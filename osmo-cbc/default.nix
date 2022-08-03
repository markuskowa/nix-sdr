{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, talloc, libosmocore, libosmo-abis, libosmo-netif
, libulfius, sqlite
}:


stdenv.mkDerivation rec {
  pname = "osmo-cbc";
  version = "0.3.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-cbc";
    rev = version;
    sha256 = "sha256-RqF+2Ua862LeDcuVcLUg2uNLglEF9PxEY1cEHKoIGOw=";
  };

  postPatch = ''
    echo "${version}" > .tarball-version
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libosmocore
    libosmo-abis
    libosmo-netif
    libulfius
    # talloc
    # sqlite
  ];
}
