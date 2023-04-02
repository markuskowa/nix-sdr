{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif }:


stdenv.mkDerivation rec {
  pname = "osmo-ggsn";
  version = "1.10.1";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-ggsn";
    rev = version;
    sha256 = "sha256-j7Szh6lDZY9ji9VAdE3D73R/WBPDo85nVB8hr4HzO7M=";
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
  ];

  meta = with lib; {
    description = "GSM Gateway GPRS Support Node (GGSN) for 2G (GSM) and 3G (UMTS)";
    homepage = "https://osmocom.org/projects/osmoggsn/wiki";
    license = licenses.agpl3Only;
  };
}
