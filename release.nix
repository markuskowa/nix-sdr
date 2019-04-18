{ pkgs ? import <nixpkgs> {} } :

with pkgs;

rec {
  odrAudioEnc = odrAudioEnc;
  fdk-aac = fdk-aac;
  rtl-sdr-kerberos = rtl-sdr-kerberos;
}
