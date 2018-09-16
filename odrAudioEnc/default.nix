{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, fdk_aacDab, alsaLib, vlc
} :

let
  version = "2.3.0";

in stdenv.mkDerivation {
  name = "odrAudioEnc-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-AudioEnc";
    rev = "v${version}";
    sha256 = "1837mfwlbh8p57w36yzllz2zmf4zwqsyqnpg8bmlp3jsfga7q1aa";
  };

  nativeBuildInputs = [ autoconf automake libtool pkgconfig ];
  buildInputs = [ zeromq fdk_aacDab alsaLib vlc ];

  configureFlags = [
    "--enable-vlc"
    "--enable-alsa"
  ];

  postPatch = ''
    # avoid invalid rpath /tmp/nix-build-*
    sed -i "/odr_audioenc_LDFLAGS/d" Makefile.am
  '';

  preConfigure = ''
    ./bootstrap
  '';

  meta = with stdenv.lib; {
    description = "DAB/DAB+ audio encoder";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = with licenses; [ asl20 lgpl21 ];
    platforms = platforms.linux;
  };
}

