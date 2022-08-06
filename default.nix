self: super:

with super;

{

  airspyAdsb = callPackage ./airspy_adsb {};

  etisnoop = callPackage ./etisnoop {};

  eti-tools = callPackage ./eti-tools {};

  eti-cmdline-rtl-sdr = callPackage ./eti-stuff { device = "rtl-sdr"; };
  eti-cmdline-rtl-tcp = callPackage ./eti-stuff { device = "rtl-tcp"; };
  eti-cmdline-airspy = callPackage ./eti-stuff { device = "airspy"; };

  fdk_aacDab = callPackage ./fdk-aac {};

  ggwave = callPackage ./ggwave {};

  libfec = callPackage ./libfec {};

  kerberossdr = callPackage ./kerberossdr {};

  nexus433 = callPackage ./nexus433 {};

  odrAudioEnc = callPackage ./odrAudioEnc {};

  odrDabMod = callPackage ./odrDabMod {};

  odrDabMux = callPackage ./odrDabMux { };

  odrDabMux_gui = callPackage ./odrDabMux/gui.nix {};

  odrEdi2Edi = callPackage ./odrEDI2EDI {};

  odrPadEnc = callPackage ./odrPadEnc {};

  odrSourceCompanion = callPackage ./odrSourceCompanion {};

  libosmo-abis = callPackage ./libosmo-abis {};

  libosmo-netif = callPackage ./libosmo-netif {};

  libosmo-sccp = callPackage ./libosmo-sccp {};

  libulfius = callPackage ./libulfius {};

  osmo-cbc = callPackage ./osmo-cbc {};

  osmo-hlr = callPackage ./osmo-hlr {};

  osmo-msc = callPackage ./osmo-msc {};

  osmo-mgw = callPackage ./osmo-mgw {};

  osmo-bsc = callPackage ./osmo-bsc {};

  osmo-bts = callPackage ./osmo-bts {};

  osmo-trx = callPackage ./osmo-trx {};

  srsran = callPackage ./srsran {};

  rtl-sdr-kerberos = callPackage ./rtl-sdr-kerberos {};

  rtptools = callPackage ./rtptools {};

  rx_tools = callPackage ./rx_tools {};

  sdr-dab = callPackage ./sdr-dab { inherit (self.gst_all_1) gstreamer gst-plugins-base; };

  waveplus-reader = callPackage ./waveplus-reader { };
}
