{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif, libosmo-sccp
, osmo-mgw, sqlite
}:


stdenv.mkDerivation rec {
  pname = "osmo-bts";
  version = "1.5.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-bts";
    rev = version;
    sha256 = "sha256-DnpzcV51LYVo+fGHph3jWehwwqG1DTKOQeGkK8Jbavw=";
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
    # libosmo-netif
    # libosmo-sccp
    # osmo-mgw
    # sqlite
  ];
}