{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-abis, libosmo-netif
}:


stdenv.mkDerivation rec {
  pname = "osmo-mgw";
  version = "1.10.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-mgw";
    rev = version;
    sha256 = "sha256-jFvKLC0V0lcxdFB2j3wXjPmhR+jHHvNUCHfo/FCAuuA=";
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
    description = "Media Gateway for handling user plane (voice) traffic in cellular networks";
    homepage = "https://osmocom.org/projects/osmo-mgw/wiki";
    license = licenses.agpl3Only;
  };
}
