{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkg-config, zeromq, alsaLib, vlc, curl
} :

let
  version = "3.1.0";

in stdenv.mkDerivation {
  pname = "odrAudioEnc";
  inherit version;

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-AudioEnc";
    rev = "v${version}";
    sha256 = "1jgagblhy3q384wz6r90wl1yfk3an7vsry8dwc0a0ld6d653hi9k";
  };

  nativeBuildInputs = [ autoconf automake libtool pkg-config ];
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

