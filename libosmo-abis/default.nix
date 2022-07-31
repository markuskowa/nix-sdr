{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, talloc, libosmocore, ortp, bctoolbox
}:


stdenv.mkDerivation rec {
  pname = "libosmo-abis";
  version = "1.3.0";

  src = fetchgit {
    url = "https://gitea.osmocom.org/osmocom/libosmo-abis";
    rev = version;
    sha256 = "sha256-dBiYrquyA+vsb7T56fNVvVa+j966mfm0kKwarzBsWvw=";
  };

  postPatch = ''
    echo "${version}" > .tarball-version
  '';

  configureFlags = [ "--disable-dahdi" ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libosmocore
    ortp
    bctoolbox
#    talloc
  ];
}
