{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, talloc, libosmocore, libosmo-abis, sqlite
}:


stdenv.mkDerivation rec {
  pname = "osmo-hlr";
  version = "1.6.1";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-hlr";
    rev = version;
    sha256 = "sha256-lFIYoDaJbVcC0A0TukRO9KDTVx31WqPPz/Z3wACJBp0=";
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

  meta = with lib; {
    description = "GSM Home Location Register";
    homepage = "https://osmocom.org/projects/osmo-hlr/wiki/OsmoHLR";
    license = licenses.agpl3Only;
  };
}
