self: super:

with super;
{
  dablin = callPackage ./dablin {};

  fdk_aacDab = callPackage ./fdk-aac {};

  odrAudioEnc = callPackage ./odrAudioEnc {};

  odrDabMod = callPackage ./odrDabMod {};

  odrDabMux = callPackage ./odrDabMux {};

  odrPadEnc = callPackage ./odrPadEnc {};
}
