{ lib, stdenv, fetchFromGitHub, autoconf, automake, libtool
} :

let
  version = "3.0.1-odr1";

in stdenv.mkDerivation {
  name = "libfec-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ka9q-fec";
    rev = "v${version}";
    sha256 = "16s02n8m11ivmqfw70z5bx1idj66q475327xfi4b5a085amdk20b";
  };

  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ ];

  postPatch = ''
    sed -i 's/ldconfig//' configure.in
  '';

  preConfigure = ''
    patchShebangs bootstrap
    ./bootstrap
  '';

  meta = with lib; {
    description = "KA9Q fec library with additonal ARM support";
    homepage = https://github.com/Opendigitalradio/ka9q-fec;
    license = licenses.lgpl21;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}
