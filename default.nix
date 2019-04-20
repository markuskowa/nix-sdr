self: super:

with super;
{
  eti-tools = callPackage ./eti-tools {};

  dablin = callPackage ./dablin {};

  dabtools = callPackage ./dabtools {};

  fdk_aacDab = callPackage ./fdk-aac {};

  libfec = callPackage ./libfec {};

  kerberossdr = callPackage ./kerberossdr {};

  odrAudioEnc = callPackage ./odrAudioEnc {};

  odrDabMod = callPackage ./odrDabMod {};

  odrDabMux = callPackage ./odrDabMux {};

  odrDabMux_gui = callPackage ./odrDabMux/gui.nix {};

  odrPadEnc = callPackage ./odrPadEnc {};

  rtl-sdr-kerberos = callPackage ./rtl-sdr-kerberos {};

  rx_tools = callPackage ./rx_tools {};
}
