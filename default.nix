self: super:

with super;

{

  airspyAdsb = callPackage ./airspy_adsb {};

  cariboulite-dtbo = callPackage ./libcariboulite/dtbo.nix {};

  etisnoop = callPackage ./etisnoop {};

  eti-tools = callPackage ./eti-tools {};

  eti-cmdline-rtl-sdr = callPackage ./eti-stuff { device = "rtl-sdr"; };
  eti-cmdline-rtl-tcp = callPackage ./eti-stuff { device = "rtl-tcp"; };
  eti-cmdline-airspy = callPackage ./eti-stuff { device = "airspy"; };

  fdk_aacDab = callPackage ./fdk-aac {};

  fdk-aac-hdc = callPackage ./fdk-aac/hdc.nix {};

  gr-nrsc5 = gnuradio3_9.pkgs.callPackage ./gr-nrsc5 {};

  ggwave = callPackage ./ggwave {};

  libfec = callPackage ./libfec {};

  kerberossdr = callPackage ./kerberossdr {};

  nexus433 = callPackage ./nexus433 {};

  nrsc5-latest = callPackage ./nrsc5 {};

  odrAudioEnc = callPackage ./odrAudioEnc {};

  odrDabMod = callPackage ./odrDabMod {};

  odrDabMux = callPackage ./odrDabMux { };

  odrDabMux_gui = callPackage ./odrDabMux/gui.nix {};

  odrEdi2Edi = callPackage ./odrEDI2EDI {};

  odrPadEnc = callPackage ./odrPadEnc {};

  odrSourceCompanion = callPackage ./odrSourceCompanion {};

  kamailio = callPackage ./kamailio {};

  libcariboulite = callPackage ./libcariboulite {};

  soapysdr-with-plugins-caribou = super.soapysdr-with-plugins.override {
    extraPackages = with self; [
      libcariboulite
      limesuite
      soapyairspy
      soapyaudio
      soapybladerf
      soapyremote
      soapyrtlsdr
    ];
  };

  libulfius = callPackage ./libulfius {};

  free-diameter = callPackage ./free-diameter {};

  open5gs = callPackage ./open5gs {};

  open5gs-webui = callPackage ./open5gs/webui.nix {};

  osmo-cbc = callPackage ./osmo-cbc {};

  osmo-smlc = callPackage ./osmo-smlc {};

  osmo-trx = callPackage ./osmo-trx {};

  osmo-stp = self.libosmo-sccp;

  srsran = callPackage ./srsran {};

  srsran-limesdr = callPackage ./srsran/limesdr.nix {};

  rtpproxy = callPackage ./rtpproxy {};

  rtl-sdr-kerberos = callPackage ./rtl-sdr-kerberos {};

  rtl-sdr-scanner-cpp = callPackage ./rtl-sdr-scanner-cpp {};

  rx_tools = callPackage ./rx_tools {};

  sdr-dab = callPackage ./sdr-dab { inherit (self.gst_all_1) gstreamer gst-plugins-base; };

  waveplus-reader = callPackage ./waveplus-reader { };

  pyhss = super.python3.pkgs.toPythonApplication self.python3.pkgs.pyhss;

  ### Python packages
  python3 = super.python3.override (old: {
    packageOverrides = super.lib.composeExtensions (old.packageOverrides or (_: _: { }))
      (pSelf: pSuper: let
        callPackage = lib.callPackageWith (self // pSelf);
      in {
        alchemyjsonschema = callPackage ./alchemyjsonschema {};
        dictknife = callPackage ./dictknife {};
        magicalimport = callPackage ./magicalimport {};
        osmo-python = callPackage ./osmo-python {};
        pyhss = callPackage ./pyhss {};
        pysctp = callPackage ./pysctp {};
      });
  });
}
