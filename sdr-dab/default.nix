{ stdenv
, fetchurl
, cmake
, pkgconfig
, fftwFloat
, glib
, gst-plugins-base
, gstreamer
, libsamplerate
, libusb
, libxml2
, pcre
, qt5
, readline
, rtl-sdr
}:
stdenv.mkDerivation {
  pname = "sdrdab-decoder";
  version = "2.0";

  src = fetchurl {
    url = https://sdr.kt.agh.edu.pl/sdrdab-decoder/downloads/sdrdab/sdrdab-v2.0_20160607.tar.gz;
    sha256 = "1ll6xbfgi0nibc2lijbvm9v6srjf41gkg7kqvf67f2cgwnjpx1p1";
  };

  postPatch = ''
    sed -i src/sdrdab/CMakeLists.txt \
      -e '/Werror/d' \
      -e '$ a target_include_directories(sdrdab PUBLIC ${gst-plugins-base.dev}/include/gstreamer-1.0 ${gstreamer.dev}/include/gstreamer-1.0)'
  '';

  buildInputs = [
    fftwFloat
    glib
    gst-plugins-base.dev
    gstreamer.dev
    libsamplerate
    libusb
    libxml2
    pcre
    qt5.qtbase
    readline
    rtl-sdr
  ];

  nativeBuildInputs = [ cmake pkgconfig ];

  meta = with stdenv.lib; {
    homepage = "https://sdr.kt.agh.edu.pl/sdrdab-decoder/";
    description = "sdrdab-decoder (also simply called sdrdab) is C++ library designed to work with RTL2832U stick (and other compatibile tuners), using it to gather and decode DAB signal.";
    licence = licenses.lgpl3;
  };
}
