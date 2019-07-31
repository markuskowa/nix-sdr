{ stdenv, fetchFromGitHub , libfec, zeromq
} :

let
  version = "20190725";

in stdenv.mkDerivation {
  name = "eti-tools-${version}";

  src = fetchFromGitHub {
    owner = "piratfm";
    repo = "eti-tools";
    rev = "65abc2651437b6062a6c03a55010a06339ff934b";
    sha256 = "1r6wbww63a5cwj4nl6lm9ww3pyfx7mz04pl9qisx2j5s61x0gcn1";
  };

  nativeBuildInputs = [ ];
  buildInputs = [ zeromq libfec ];

  postPatch = ''
    # enable FEC
    sed -i 's/#CFLAGS+= -DHAVE_FEC/CFLAGS+= -DHAVE_FEC/' Makefile
    sed -i 's/#LDFLAGS+= -lfec/LDFLAGS+= -lfec/' Makefile
    # enable ZeroMQ
    sed -i 's/#CFLAGS+= -DHAVE_ZMQ/CFLAGS+= -DHAVE_ZMQ/' Makefile
    sed -i 's/#LDFLAGS+= -lzmq/LDFLAGS+= -lzmq/' Makefile
  '';

  preInstall = ''
    export DESTDIR=$out
  '';

  postInstall = ''
    mkdir -p $out/bin
    mv $out/usr/bin/* $out/bin/
    rm -r $out/usr
  '';

  meta = with stdenv.lib; {
    description = "Tools to handle DAB ETI streams";
    homepage = https://github.com/piratfm/eti-tools;
    license = licenses.mpl20;
    maintainers = maintainers.markuskowa;
    platforms = platforms.linux;
  };
}

