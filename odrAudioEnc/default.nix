{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, alsaLib, vlc, curl
} :

let
  version = "2.6.0";

in stdenv.mkDerivation {
  name = "odrAudioEnc-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-AudioEnc";
    rev = "v${version}";
    sha256 = "1llpc0b2idqb55744fmya2xkk3rp6lq2vn9rcazn25h2440avwgi";
  };

  nativeBuildInputs = [ autoconf automake libtool pkgconfig ];
  buildInputs = [ zeromq alsaLib vlc curl ];

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
    maintainers = [ maintainers.markuskowa ];
  };
}

