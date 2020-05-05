{ stdenv, fetchFromGitHub, cmake, pkgconfig, fdk_aacDab
, mpg123, SDL2, gnome3, faad2, pcre
} :

let
  version = "1.13.0";

in stdenv.mkDerivation {
  name = "dablin-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "dablin";
    rev = "${version}";
    sha256 = "0143jnhwwh4din6mlrkbm8m2wm8vnrlk0yk9r5qcvj70r2314bgq";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ fdk_aacDab faad2 mpg123 SDL2 gnome3.gtkmm pcre ];

  cmakeFlags = [ "-DUSE_FDK-AAC=1" ];

  meta = with stdenv.lib; {
    description = "Play DAB/DAB+ from ETI-NI aligned stream";
    homepage = https://github.com/Opendigitalradio/dablin;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.markuskowa ];
  };
}

