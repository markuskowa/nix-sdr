self: super:

with super;
{
  odrAudioEnc = callPackage ./odrAudioEnc {};
  odrDabMux = callPackage ./odrDabMux {};
  fdk_aacDab = callPackage ./fdk-aac {};
}
