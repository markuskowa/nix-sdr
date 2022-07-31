{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, talloc, libosmocore, libosmo-abis, sqlite
, lksctp-tools
}:


stdenv.mkDerivation rec {
  pname = "libosmo-netif";
  version = "1.2.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/osmocom/libosmo-netif";
    rev = version;
    sha256 = "sha256-Zy4wgEztY8fb9BzkUmMKwnFemgeae8MEp48OZhitS8I=";
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
    lksctp-tools
    # libosmo-abis
    # talloc
    # sqlite
  ];
}