{ stdenv, lib, fetchFromGitHub, autoconf, automake, libtool
, pkg-config, zeromq, alsa-lib, vlc, curl, gst_all_1
} :

let
  version = "3.5.0";

in stdenv.mkDerivation {
  pname = "odrAudioEnc";
  inherit version;

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-AudioEnc";
    rev = "v${version}";
    sha256 = "sha256-H0Z8GOVcdm7F6Ph/KUo44lHgbVlV//ZfaDN/uMagXZ4=";
  };

  patches = [ ./gcc-cstdint.patch ];

  nativeBuildInputs = [ autoconf automake libtool pkg-config ];
  buildInputs = [
    zeromq
    alsa-lib
    vlc
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    curl
  ];

  configureFlags = [
    "--enable-vlc"
    "--enable-alsa"
    "--enable-gst"
  ];

  postPatch = ''
    # avoid invalid rpath /tmp/nix-build-*
    sed -i "/odr_audioenc_LDFLAGS/d" Makefile.am
  '';

  preConfigure = ''
    ./bootstrap
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "DAB/DAB+ audio encoder";
    homepage = http://www.opendigitalradio.org/mmbtools;
    license = with licenses; [ asl20 lgpl21 ];
    platforms = platforms.linux;
    maintainers = [ maintainers.markuskowa ];
  };
}

