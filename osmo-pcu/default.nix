{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif, libosmo-sccp }:


stdenv.mkDerivation rec {
  pname = "osmo-pcu";
  version = "1.2.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-pcu";
    rev = version;
    sha256 = "sha256-wZLTDvqVxP0FXV0VQH5KuigwbgzBipwL5JkTDp5Mzrc=";
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
  ];

  meta = with lib; {
    description = "Implementation of a GSM/GPRS Packet Control Unit";
    homepage = "https://osmocom.org/projects/osmopcu/wiki";
    license = licenses.agpl3Only;
  };
}
