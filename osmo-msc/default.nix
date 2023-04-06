{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif, libosmo-sccp
, osmo-mgw, osmo-hlr, lksctp-tools
, sqlite
}:


stdenv.mkDerivation rec {
  pname = "osmo-msc";
  version = "1.10.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-msc";
    rev = version;
    sha256 = "sha256-CVyjSo+QFDLcow6XAcudhQ7LOnbCSHeYVTzTMh7KEwg=";
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

  meta = with lib; {
    description = "GSM Mobile Switching Centre (MSC) for 2G (GSM) and 3G (UMTS)";
    homepage = "https://osmocom.org/projects/osmomsc/wiki";
    license = licenses.agpl3Only;
  };
}
