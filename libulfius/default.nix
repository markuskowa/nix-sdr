{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, gnutls, libmicrohttpd, zlib, curl, jansson, orcania, yder
}:


stdenv.mkDerivation rec {
  pname = "libulfius";
  version = "2.7.10";

  src = fetchFromGitHub {
    owner = "babelouest";
    repo = "ulfius";
    rev = "v${version}";
    sha256 = "sha256-HJU2b8/UbPVdIna8CpYmQlKvieS/5pBSj292Ax0sN5A=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    gnutls
    libmicrohttpd
    zlib
    curl
    jansson
  ];

  propagatedBuildInputs = [
    orcania
    yder
  ];

  meta = with lib; {
    description = "HTTP Framework for REST Applications in C";
    homepage = "https://github.com/babelouest/ulfius";
    license = licenses.lgpl21Only;
  };
}
