{ stdenv, python2, fetchFromGitHub } :

stdenv.mkDerivation {
  pname = "waveplus-reader";
  version = "20210722-mk";

  src = fetchFromGitHub {
    owner = "markuskowa";
    repo = "waveplus-reader";
    rev = "e2eb096efb0da543cc9de723d172356e5c1b4e84";
    sha256 = "sha256-d+uqzbMMPh7Ydd2ZAKmzN5k2EgWserqntZ/Nh844DyQ=";
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
