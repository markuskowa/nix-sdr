{ stdenv, fetchFromGitHub , libfec, zeromq
} :

let
  version = "20200405";

in stdenv.mkDerivation {
  name = "eti-tools-${version}";

  src = fetchFromGitHub {
    owner = "piratfm";
    repo = "eti-tools";
    rev = "8f07a2103c21eccf904eda82931f15c50d27928a";
    sha256 = "1ja559iabf9r2xb9042ydghgngcwzbfimr7cx1bxbfwyd2iy70bq";
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

