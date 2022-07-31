{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, talloc, libosmocore, libosmo-abis, sqlite
}:


stdenv.mkDerivation rec {
  pname = "osmo-hlr";
  version = "1.5.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-hlr";
    rev = version;
    sha256 = "sha256-RDpFCAFcS3OfLgPls4s+OjtYCt1QAlmr57Xh/AbMQhs=";
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
    talloc
    sqlite
  ];
}
