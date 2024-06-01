{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, talloc, libosmocore, fftwFloat
, libusb1, limesuite, libbladeRF
}:


stdenv.mkDerivation rec {
  pname = "osmo-trx";
  version = "1.6.2";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-trx";
    rev = version;
    hash = "sha256-rd75bnorqbiRC3mDOTgl7eI0yMCiJsjodjHTQQ7Glg8=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  configureFlags = [
    "--with-bladerf"
    "--with-lms"
    "--with-ipc"
  ] ++ lib.optional stdenv.isAarch64 "--with-vfpv4";

  preConfigure = ''
    export configureFlagsArray=("--with-systemdsystemunitdir=$out/lib/systemd")
  '';

  buildInputs = [
    libosmocore
    libusb1
    limesuite
    libbladeRF
    fftwFloat
  ];

  meta = with lib; {
    description = "SDR transceiver that implements the Layer 1 physical layer of a BTS";
    homepage = "https://osmocom.org/projects/osmotrx/wiki/OsmoTRX";
    license = licenses.agpl3Only;
  };
}
