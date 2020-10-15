self: super:

with super;
{

  airspyAdsb = callPackage ./airspy_adsb {};

  etisnoop = callPackage ./etisnoop {};

  eti-tools = callPackage ./eti-tools {};

  eti-cmdline-rtl-sdr = callPackage ./eti-stuff { device = "rtl-sdr"; };
  eti-cmdline-rtl-tcp = callPackage ./eti-stuff { device = "rtl-tcp"; };
  eti-cmdline-airspy = callPackage ./eti-stuff { device = "airspy"; };

  dablin = callPackage ./dablin {};

  fdk_aacDab = callPackage ./fdk-aac {};

  libfec = callPackage ./libfec {};

  kerberossdr = callPackage ./kerberossdr {};

  odrAudioEnc = callPackage ./odrAudioEnc {};

  odrDabMod = callPackage ./odrDabMod {};

  odrDabMux = callPackage ./odrDabMux { };

  odrDabMux_gui = callPackage ./odrDabMux/gui.nix {};

  odrPadEnc = callPackage ./odrPadEnc {};

  odrSourceCompanion = callPackage ./odrSourceCompanion {};

  rtl-sdr-kerberos = callPackage ./rtl-sdr-kerberos {};

  rtptools = callPackage ./rtptools {};

  rx_tools = callPackage ./rx_tools {};
}
