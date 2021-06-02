{ lib, stdenv, fetchFromGitHub, cmake
, python3, SDL2, libGL
} :

stdenv.mkDerivation rec {
  pname = "ggwave";
  version = "2021-05-28";

  src = fetchFromGitHub {
    owner = "ggerganov";
    repo = pname;
    rev = "c7bf8ab395d61cfe9179750bd983611d0c859bc9";
    sha256 = "0i4jwp6b7w8n8bn1c5d9lz2i5x3i49yhnswnl2d1s0yama5svg8i";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ python3 SDL2 libGL ];

  postInstall = ''
    cp bin/* $out/bin
  '';

  meta = with lib; {
    description = "Tiny data-over-sound library";
    homepage = "https://github.com/ggerganov/ggwave";
    license = licenses.mit;
    maintainers = [ maintainers.markuskowa ];
  };
}
