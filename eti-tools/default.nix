{ stdenv, fetchFromGitHub , libfec, zeromq
} :

let
  version = "20180905";

in stdenv.mkDerivation {
  name = "eti-tools-${version}";

  src = fetchFromGitHub {
    owner = "piratfm";
    repo = "eti-tools";
    rev = "1906876f3f00b5284ec8287b1f62e0e5537abcc9";
    sha256 = "1vjckyrvr6sqwf8fyxwrdn0ih9gx1iambx72l1vk9h51xbj8l0b5";
  };

  nativeBuildInputs = [ ];
  buildInputs = [ zeromq libfec ];

  postPatch = ''
    # enable FEC
    sed -i 's/#CFLAGS+= -DHAVE_FEC/CFLAGS+= -DHAVE_FEC/' Makefile
    sed -i 's/#LDFLAGS+= -lfec/LDFLAGS+= -lfec/' Makefile
  '';

  installPhase = ''
    mkdir -p $out/bin

    for i in ni2http ts2na na2ts na2ni edi2eti eti2zmq; do
      cp $i $out/bin
    done
  '';

  meta = with stdenv.lib; {
    description = "Tools to handle DAB ETI streams";
    homepage = https://github.com/piratfm/eti-tools;
    license = licenses.mpl20;
    maintainers = maintainers.markuskowa;
    platforms = platforms.linux;
  };
}

