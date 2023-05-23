{ lib, stdenv, fetchFromGitHub,
  autoconf, automake, libtool, cmake,
  rtl-sdr, libao, fftwFloat
} :
let
  src_faad2 = fetchFromGitHub {
    owner = "knik0";
    repo = "faad2";
    rev = "df42c6fc018552519d140e3d8ffe7046ed48b0cf";
    sha256 = "sha256-rpq9bFSvypxtEssoXIGC/45uUF4jSwETwlnLWwYyqDk=";
  };

  version = "2023-04-18";

in stdenv.mkDerivation {
  pname = "nrsc5";
  inherit version;

  src = fetchFromGitHub {
    owner = "theori-io";
    repo = "nrsc5";
    rev = "eb76474193f228fd8fa697fc267b123c6c845a22";
    sha256 = "sha256-+vXZDQ5MQWp5qsjWndtVmo8+M0XiOH9O0iDTMxeitEc=";
  };

  postUnpack = ''
    export srcRoot=`pwd`
    export faadSrc="$srcRoot/faad2-prefix/src/faad2_external"
    mkdir -p $faadSrc
    cp -r ${src_faad2}/* $faadSrc
    chmod -R u+w $faadSrc
  '';

  postPatch = ''
    sed -i '/GIT_REPOSITORY/d' CMakeLists.txt
    sed -i '/GIT_TAG/d' CMakeLists.txt
    sed -i "s:set (FAAD2_PREFIX .*):set (FAAD2_PREFIX \"$srcRoot/faad2-prefix\"):" CMakeLists.txt
  '';

  nativeBuildInputs = [ cmake autoconf automake libtool ];
  buildInputs = [ rtl-sdr libao fftwFloat ];

  cmakeFlags = [ "-DUSE_COLOR=ON" "-DUSE_FAAD2=ON" "-DUSE_SSE=ON"];

  meta = with lib; {
    homepage = "https://github.com/theori-io/nrsc5";
    description = "HD-Radio decoder for RTL-SDR";
    platforms = lib.platforms.linux;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ markuskowa ];
  };
}

