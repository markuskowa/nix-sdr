{ stdenv, fetchFromGitHub, cmake, pkgconfig, fdk_aacDab
, mpg123, SDL2, gnome3, faad2, pcre
} :

let
  version = "1.10.0";

in stdenv.mkDerivation {
  name = "dablin-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "dablin";
    rev = "${version}";
    sha256 = "1cz8br3v4idd25k0326vqkc3clph29d1c2i8s9jmqs36iykn994d";
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

