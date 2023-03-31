{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, sofia_sip, glib
}:

stdenv.mkDerivation rec {
  pname = "osmo-sip-connector";
  version = "1.6.2";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-sip-connector";
    rev = version;
    sha256 = "sha256-vsPtNeh6Yi5fQb+E90OF4/Hnjl9T5nMf9EMBhzpIA2I=";
  };

  postPatch = ''
#    echo "${version}" > .tarball-version
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libosmocore
    sofia_sip
    glib
    # libosmo-abis
    # libosmo-netif
  ];

  meta = with lib; {
    description = "Interface between Osmo-MSC/MNCC and SIP";
    homepage = "https://osmocom.org/projects/osmo-sip-connector/wiki";
    license = licenses.agpl3Only;
  };
}
