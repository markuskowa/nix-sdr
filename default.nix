self: super:

with super;
{
  odrAudioEnc = callPackage ./odrAudioEnc {};
  fdk_aacDab = callPackage ./fdk-aac {};
}
