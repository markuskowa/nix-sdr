{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-netif, lksctp-tools
}:


stdenv.mkDerivation rec {
  pname = "libosmo-sccp";
  version = "1.6.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/osmocom/libosmo-sccp";
    rev = version;
    sha256 = "sha256-jXfYMdgpeLcQIxbi2WkG0CAWvwaqBE3yPmqA9eTWdL0=";
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
    libosmo-netif
    lksctp-tools
  ];

  meta = with lib; {
    description = "Implementation of telecom signaling protocols and OsmoSTP";
    homepage = "https://osmocom.org/projects/osmo-stp/wiki";
    license = licenses.agpl3Only;
  };
}
