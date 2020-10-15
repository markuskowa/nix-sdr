{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, alsaLib, vlc, curl
} :

let
  version = "3.0.0";

in stdenv.mkDerivation {
  name = "odrAudioEnc-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-AudioEnc";
    rev = "v${version}";
    sha256 = "1v0ipw194alijaklfg7lq8hypiay7k09g1hqvp5g0w04g25ka4gn";
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

