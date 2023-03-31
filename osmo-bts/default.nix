{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif
}:


stdenv.mkDerivation rec {
  pname = "osmo-bts";
  version = "1.6.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-bts";
    rev = version;
    sha256 = "sha256-RSWXWQn3DAPtThUbthyXrSFSQhHzKaH/m1f6/MCojzM=";
  };

  preConfigure = ''
    export configureFlagsArray=("--with-systemdsystemunitdir=$out/lib/systemd"
        "--enable-trx")
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
    description = "GSM Base Transceiver Station";
    homepage = "https://osmocom.org/projects/osmobts/wiki";
    license = licenses.agpl3Only;
  };
}
