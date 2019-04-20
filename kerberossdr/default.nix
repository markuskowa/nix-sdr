{ stdenv, fetchurl, fetchFromGitHub, python3, python3Packages
, rtl-sdr-kerberos, php
} :

let
  version = "20190408";

  pyapril = python3Packages.buildPythonPackage rec {
    pname = "pyAPRiL";
    version = "1.1.post1";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "bb4d654947f878ee3f20d29bcf933b0842963df7a8206663f17b3cca401cafe8";
    };

    preConfigure = ''
      substituteInPlace setup.py --replace 'open("README.md", "r")' "open('README.md',encoding='utf-8')"
      cat setup.py
    '';

    doCheck = false;

    meta = with stdenv.lib; {
      homepage = "https://github.com/petotamas/APRiL";
      license = licenses.gpl3;
      description = "A python based passive radar library";
    };
  };

  pyargus = python3Packages.buildPythonPackage rec {
    pname = "pyargus";
    version = "1.0.post3";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "0m3m9ni4a291afs4cy0k1amrl4hjc6iy5l9v6zf3zqbz0gn6vrvi";
    };

    preConfigure = ''
      substituteInPlace setup.py --replace 'open("README.md", "r")' "open('README.md',encoding='utf-8')"
      cat setup.py
    '';

    doCheck = false;

    meta = with stdenv.lib; {
      homepage = "https://github.com/petotamas/";
      license = licenses.gpl3;
      description = "Python package implementing signal processing algorithms applicable in antenna arrays";
    };
  };

  peakutils = python3Packages.buildPythonPackage rec {
    pname = "PeakUtils";
    version = "1.3.2";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "0m69flr448sq370s9j9fa2d2rj6ic8dj4zlwzki1j0ig2c4zdw9c";
    };

    #preConfigure = ''
    #  substituteInPlace setup.py --replace 'open("README.md", "r")' "open('README.md',encoding='utf-8')"
    #  cat setup.py
    #'';

    propagatedBuildInputs = with python3Packages; [ numpy scipy ];

    doCheck = false;

    meta = with stdenv.lib; {
      homepage = "https://github.com/petotamas/";
      license = licenses.gpl3;
      description = "Python package implementing signal processing algorithms applicable in antenna arrays";
    };
  };

  python = python3.withPackages (ps: with ps; [
    numpy
    matplotlib
    scipy
    cairocffi
    pyapril
    pyargus
    pyqtgraph
    peakutils
    bottle
    paste
  ]);

in stdenv.mkDerivation {
  name = "kerberossdr-${version}";

  src = fetchFromGitHub {
    owner = "rtlsdrblog";
    repo = "kerberossdr";
    rev = "348db8d56b916f55c5efe3269369f4d6ecede3ed";
    sha256 = "0jvf5lmywj27mhj1ilih26bi35ikyfzpq4f4hf7kcc0kjpl2vpkl";
  };

  postPatch = ''
    substituteInPlace _GUI/hydra_main_window.py --replace "/ram/" "_webDisplay/"
    substituteInPlace _webDisplay/DOA_res_write.py --replace "/ram/" "_webDisplay/"
  '';

  nativeBuildInputs = [ ];
  buildInputs = [ python rtl-sdr-kerberos ];

  buildPhase = ''
    make -C _receiver/C
  '';

  installPhase = ''
    mkdir -p $out
    cp -r _GUI $out
    cp -r _dataFiles $out
    cp -r _receiver $out
    cp -r _signalProcessing $out
    cp -r _webDisplay $out
    cp -r static $out
    cp -r views $out

    rm $out/_webDisplay/pr.jpg
    rm $out/_webDisplay/DOA_value.html
    rm $out/_webDisplay/spectrum.jpg
    rm $out/_webDisplay/sync.jpg
    rm $out/_webDisplay/doa.jpg

    TMPDIR=/tmp/kerberossdr
    #ln -s  $TMPDIR/pr.jpg            $out/_webDisplay/pr.jpg
    #ln -s  $TMPDIR/DOA_value.html    $out/_webDisplay/DOA_value.html
    #ln -s  $TMPDIR/spectrum.jpg      $out/_webDisplay/spectrum.jpg
    #ln -s  $TMPDIR/sync.jpg          $out/_webDisplay/sync.jpg
    #ln -s  $TMPDIR/doa.jpg           $out/_webDisplay/doa.jpg

    rm $out/_receiver/C/*.h $out/_receiver/C/*.c $out/_receiver/C/Makefile

    cat << EOF >> $out/run.sh
    #!${stdenv.shell}
    TMPDIR=/tmp/kerberossdr

    BUFF_SIZE=256 #Must be a power of 2. Normal values are 128, 256. 512 is possible on a fast PC. NOTE: Please do not change at the moment. In future versions this may work.
    IPADDR=127.0.0.1

    mkdir -p \$TMPDIR/_receiver/C
    # Remake Controller FIFOs
    rm $TMPDIR/_receiver/C/gate_control_fifo
    mkfifo \$TMPDIR/_receiver/C/gate_control_fifo

    rm \$TMPDIR/_receiver/C/sync_control_fifo
    mkfifo \$TMPDIR/_receiver/C/sync_control_fifo

    rm \$TMPDIR/_receiver/C/rec_control_fifo
    mkfifo \$TMPDIR/_receiver/C/rec_control_fifo

    cp -r $out/* \$TMPDIR
    chmod -R u+w \$TMPDIR

    cd \$TMPDIR

    #$out/_receiver/C/rtl_daq \$BUFF_SIZE 2>/dev/null 1| \
    #  $out/_receiver/C/sync \$BUFF_SIZE 2>/dev/null 1| \
    #  $out/_receiver/C/gate \$BUFF_SIZE 2>/dev/null | \
    #  ${python}/bin/python -O _GUI/hydra_main_window.py &>/dev/null \$BUFF_SIZE \$IPADDR &

    $out/_receiver/C/rtl_daq \$BUFF_SIZE 1| \
      $out/_receiver/C/sync \$BUFF_SIZE  1| \
      $out/_receiver/C/gate \$BUFF_SIZE  | \
      ${python}/bin/python -O $out/_GUI/hydra_main_window.py \$BUFF_SIZE \$IPADDR &


    # Start PHP webserver which serves the updating images
    ${php}/bin/php -S \$IPADDR:8081 -t _webDisplay

    EOF

    chmod +x $out/run.sh
  '';

  meta = with stdenv.lib; {
    description = "";
    homepage = https://;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}

