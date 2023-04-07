{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, talloc, libosmocore, libosmo-abis, libosmo-netif
, libulfius, sqlite, jansson, gnutls, zlib, libmicrohttpd
, python3, lksctp-tools
}:

let
  python = python3.withPackages (ps: [ ps.requests ] );

in stdenv.mkDerivation rec {
  pname = "osmo-cbc";
  version = "0.4.1";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-cbc";
    rev = version;
    sha256 = "sha256-Seaxwx9n7pkCIcpHN3ekdOYYlnhpjpPzHXuAe2CN6Tg=";
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
    lksctp-tools
    libulfius
    jansson
    zlib
    libmicrohttpd
    gnutls
    python
  ];

  postInstall = ''
    cp contrib/cbc-apitool.py $out/bin/cbc-apitool
  '';

  meta = with lib; {
    description = "Minimal 3GPP Cell Broadcast Centre";
    homepage = "https://osmocom.org/projects/osmo-cbc/wiki";
    license = licenses.agpl3Only;
  };
}
