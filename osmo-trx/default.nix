{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, talloc, libosmocore
, libusb1, limesuite, fftwFloat
}:


stdenv.mkDerivation rec {
  pname = "osmo-trx";
  version = "1.4.1";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-trx";
    rev = version;
    sha256 = "sha256-HEjThhU2+ofXOaQK2prRrbcQi4W8XDkx7yFChc490YI=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  preConfigure = ''
    export configureFlagsArray=("--with-systemdsystemunitdir=$out/lib/systemd"
        "--with-lms" "--with-ipc")
  '';

  buildInputs = [
    libosmocore
    libusb1
    limesuite
    fftwFloat
  ];
}
