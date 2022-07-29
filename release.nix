{ pkgs ? import <nixpkgs> {} } :

with pkgs;

{
  inherit (pkgs)
  odrAudioEnc
  odrDabMux
  odrDabMux_gui
  odrDabMod
  odrPadEnc
  fdk-aac
  rtl-sdr-kerberos
  srsran;
}
