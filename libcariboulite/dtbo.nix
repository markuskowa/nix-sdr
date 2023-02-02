{ lib, stdenv, libcariboulite, dtc } :

stdenv.mkDerivation {
  pname = "bcariboulite-dtbo";
  version = "2023-01-20-unstable";

  inherit (libcariboulite) src;

  nativeBuildInputs = [ dtc ];
  buildPhase = ''
    cd software/devicetrees
    dtc -O dtb -o cariboulite.dtbo -b 0 -@ cariboulite-overlay.dts
  '';

  installPhase = ''
    mkdir -p $out/share/raspberrypi/boot/overlays

    cp cariboulite.dtbo $out/share/raspberrypi/boot/overlays/
    cp cariboulite-overlay.dts $out/share/raspberrypi/boot/overlays/
  '';
}
