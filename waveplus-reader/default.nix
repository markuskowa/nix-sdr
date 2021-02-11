{ stdenv, python2, fetchFromGitHub } :

stdenv.mkDerivation {
  pname = "waveplus-reader";
  version = "20201204-mk";

  src = fetchFromGitHub {
    owner = "markuskowa";
    repo = "waveplus-reader";
    rev = "ba86e2ab857d0b673150adaf03c6c0162d8a3383";
    sha256 = "13835k8i6kyfkz3zcbci1irkbq236aqpyy2caa7n7rwnxdhbw45s";
  };

  buildInputs = [ (python2.withPackages (ps: [ ps.bluepy ])) ];

  prePatch = ''
    echo "#!/usr/bin/env python" > read_waveplus
    cat read_waveplus.py >> read_waveplus
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 read_waveplus $out/bin/read_waveplus
  '';
}
