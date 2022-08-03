{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, libosmocore, ortp, bctoolbox
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
  ];

  meta = with lib; {
    description = "A-bis interface library";
    homepage = "https://osmocom.org/projects/libosmo-abis";
    license = licenses.agpl3Only;
  };
}
