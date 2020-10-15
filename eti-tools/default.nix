{ stdenv, fetchFromGitHub , libfec, zeromq
} :

let
  version = "20200926";

in stdenv.mkDerivation {
  name = "eti-tools-${version}";

  src = fetchFromGitHub {
    owner = "piratfm";
    repo = "eti-tools";
    rev = "c7ef54b72833b41cf59b23156f144b64b21ce5e1";
    sha256 = "09hnxbx0czdgjph98g06zkk59xs9b2mznsypdyxzz9fmclz8j6i8";
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

  postBuild = ''
#    make ni2http
  '';

  preInstall = ''
    export DESTDIR=$out
  '';

  postInstall = ''
    mkdir -p $out/bin
    mv $out/usr/bin/* $out/bin/
    rm -r $out/usr

#    cp ni2http $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Tools to handle DAB ETI streams";
    homepage = https://github.com/piratfm/eti-tools;
    license = licenses.mpl20;
    maintainers = maintainers.markuskowa;
    platforms = platforms.linux;
  };
}

