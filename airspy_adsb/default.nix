{ stdenv, fetchurl, libusb1 } :

let
  version = "1.37";
  rpath = stdenv.lib.makeLibraryPath [ libusb1 ]
          + ":${stdenv.cc.cc.lib}/lib64";
in

stdenv.mkDerivation {
  name = "airspy-adsb-${version}";

  src = fetchurl {
    url = "http://airspy.com/?ddownload=3758";
    sha256 = "15yzhqb70acvfrqh5ibmb85ljpfz5xn3pf7q6c2x1ay7cf04pqpp";
    name = "airspy.tar.gz";
  };

  buildInputs = [ libusb1 ];

  unpackCmd = "mkdir root; tar -x -C root -f $curSrc";

  dontStrip = true;

  installPhase = ''
      mkdir -p $out/bin

      obj=airspy_adsb
      cp $obj $out/bin

      INTERP=$(cat $NIX_CC/nix-support/dynamic-linker)

      patchelf --set-interpreter "$INTERP" "$out/bin/$obj"
      patchelf --set-rpath ${rpath} "$out/bin/$obj"
  '';

  meta = {
    description = "ADS-B decoder for the AirSpy SDR";
    homepage = http://airspy.com/download;
    license = stdenv.lib.licenses.free;
    platforms = [ "x86_64-linux" ];
  };
}
