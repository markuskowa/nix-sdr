{ stdenv, fetchFromGitHub, autoreconfHook } :

let
  version = "1.22";

in stdenv.mkDerivation {
  pname = "rtptools";
  inherit version;

  src = fetchFromGitHub {
    owner = "irtlab";
    repo = "rtptools";
    rev = version;
    sha256 = "06jfrcb4kyzh00wi3ikvkgjfhbzh7bp9fb584im2gmjpv8dabfkd";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = with stdenv.lib; {
    description = "Simple command line tools for processing RTP data";
    homepage = "http://www.cs.columbia.edu/irt/software/rtptools/";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}

