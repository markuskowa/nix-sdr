{ stdenv, fetchFromGitHub, autoconf, automake, libtool
, pkgconfig, zeromq, fdk_aacDab, alsaLib, vlc
} :

let
  version = "2.4.1";

in stdenv.mkDerivation {
  name = "odrAudioEnc-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "ODR-AudioEnc";
    rev = "v${version}";
    sha256 = "0vnnkbvs8clsysh7lkccpw7ipwn9qxbv92bgmvx4dm9cxdm7jcx8";
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
    maintainers = [ maintainers.markuskowa ];
  };
}

