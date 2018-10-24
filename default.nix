self: super:

with super;
{
  eti-tools = callPackage ./eti-tools {};

  dablin = callPackage ./dablin {};

  dabtools = callPackage ./dabtools {};

  fdk_aacDab = callPackage ./fdk-aac {};

  libfec = callPackage ./libfec {};

  odrAudioEnc = callPackage ./odrAudioEnc {};

  odrDabMod = callPackage ./odrDabMod {};

  odrDabMux = callPackage ./odrDabMux {};

  odrDabMux_gui = callPackage ./odrDabMux/gui.nix {};

  odrPadEnc = callPackage ./odrPadEnc {};

  rx_tools = callPackage ./rx_tools {};
}
