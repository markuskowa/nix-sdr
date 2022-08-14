{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
} :

let
  handleTest = t: (import "${nixpkgs}/nixos/tests/make-test-python.nix") (import t);
  pkgs = (import nixpkgs) { overlays = [ (import ./default.nix) ]; };

in {
  inherit (pkgs)
  odrAudioEnc
  odrDabMux
  odrDabMux_gui
  odrDabMod
  odrPadEnc
  fdk-aac
  rtl-sdr-kerberos
  osmo-bsc
  srsran;

  tests = {
    odr = handleTest ./tests/odr.nix {};
    srsran = handleTest ./tests/srsran.nix {};
    srsran-nitb = handleTest ./tests/srsran-nitb.nix {};
    open5gs-nitb = handleTest ./tests/open5gs.nix {};
    osmocom = handleTest ./tests/osmocom.nix {};
  };
}
