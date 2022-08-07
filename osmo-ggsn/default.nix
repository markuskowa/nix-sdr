{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif }:


stdenv.mkDerivation rec {
  pname = "osmo-ggsn";
  version = "1.9.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-ggsn";
    rev = version;
    sha256 = "sha256-XRFg7se9ICYchJZlB86ml+73vDlZZIZ+4bVymfA2wSo=";
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
