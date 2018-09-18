{ stdenv, fetchFromGitHub, cmake, pkgconfig, fdk_aacDab
, mpg123, SDL2, gnome3, faad2, pcre
} :

let
  version = "1.9.0";

in stdenv.mkDerivation {
  name = "dablin-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "dablin";
    rev = "${version}";
    sha256 = "1bjay6nd7q48d7dc4xh5wfl6wi6rgfzx5lsgn1idypnpp08zqrrq";
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

