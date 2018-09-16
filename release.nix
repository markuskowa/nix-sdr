{ pkgs ? import <nixpkgs> {} } :

with pkgs;

rec {
  odrAudioEnc = odrAudioEnc;
  fdk-aac = fdk-aac;
}
