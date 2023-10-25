{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, talloc, libosmocore, libosmoabis, libosmo-netif
, libulfius, sqlite, jansson, gnutls, zlib, libmicrohttpd
, python3, lksctp-tools
}:

let
  python = python3.withPackages (ps: [ ps.requests ] );

in stdenv.mkDerivation rec {
  pname = "osmo-cbc";
  version = "0.4.2";

  src = fetchgit {
    url = "https://gitea.osmocom.org/cellular-infrastructure/osmo-cbc";
    rev = version;
    sha256 = "sha256-3C5PxXl2d7vfZIOf1xgBmrmFdsxM8nCMG3bb+I0s128=";
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
    libosmoabis
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
