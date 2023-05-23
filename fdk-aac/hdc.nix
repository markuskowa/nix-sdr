{ stdenv, lib, fetchFromGitHub, autoconf, automake, libtool
} :

stdenv.mkDerivation {
  pname = "fdk-aac-hdc";
  version = "2017-08-17";

  src = fetchFromGitHub {
    owner = "argilo";
    repo = "fdk-aac";
    rev = "3b63dab59416a629f3de82463eb3875319a086d5";
    sha256 = "sha256-7LV7lewh/XkmoU9m5iBqpZvVDYnBcYjte5phQbtU3/k=";
  };

  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with lib; {
    description = "AAC+ library with NRSC5/HDC support";
    homepage = "https://github.com/argilo/fdk-aac/tree/hdc-encoder";
    #license = licenses.Fraunhofer;
    platforms = platforms.linux;
    maintainers = [ maintainers.markuskowa ];
  };
}

