{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, libosmo-sccp
}:

stdenv.mkDerivation rec {
  pname = "osmo-smlc";
  version = "0.2.4";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-smlc";
    rev = version;
    sha256 = "sha256-ypqUe1ZqqaVqE1FucfuP6kJ/3qdcSaYarMbnDnTAUVA=";
  };

  outputs = [ "out" "doc" ];

  postPatch = ''
    echo "${version}" > .tarball-version
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libosmocore
    libosmo-sccp
  ];

  meta = with lib; {
    description = "Osmocom Serving Mobile Location Centre";
    homepage = "https://osmocom.org/projects/osmo-smlc/wiki";
    license = licenses.agpl3Only;
  };
}
