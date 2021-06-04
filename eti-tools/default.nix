{ stdenv, fetchFromGitHub , libfec, zeromq
} :

let
  version = "20210109";

in stdenv.mkDerivation {
  name = "eti-tools-${version}";

  src = fetchFromGitHub {
    owner = "piratfm";
    repo = "eti-tools";
    rev = "d343acd5b6bd593360911a0023b291d4291f4712";
    sha256 = "0i22fs9wkj09r5smxgim4r1jhfjbw3c455qbwy8hm583dgwkiidh";
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

