{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif, osmo-hlr
, osmo-ggsn, c-ares }:


stdenv.mkDerivation rec {
  pname = "osmo-sgsn";
  version = "1.10.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-sgsn";
    rev = version;
    sha256 = "sha256-tjExV8XigPEZ5gOCEoWfjhtGJVa5Ja3GHnpSovradak=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libosmocore
    libosmo-abis
    libosmo-netif
    osmo-ggsn
    osmo-hlr
    c-ares
  ];

  meta = with lib; {
    description = "GSM Serving GPRS Support Node (SGSN) for 2G (GSM) and 3G (UMTS)";
    homepage = "https://osmocom.org/projects/osmosgsn/wiki";
    license = licenses.agpl3Only;
  };
}
