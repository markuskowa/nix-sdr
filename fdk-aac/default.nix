{ stdenv, fetchFromGitHub, autoconf, automake, libtool
} :

let
  version = "20180307";

in stdenv.mkDerivation {
  name = "fdk-aac-${version}";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "fdk-aac";
    rev = "3eab23670d4d9fb2a8ee01c1be7b4acfc14c1552";
    sha256 = "0j1bpy25kqwf0bm04jnkbk31nj4ksmh76rg4daq0sbfpzwcfch0a";
  };

  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with stdenv.lib; {
    description = "Fraunhofer AAC+ library with DAB+ support";
    homepage = https://github.com/Opendigitalradio/fdk-aac;
    #license = licenses.Fraunhofer;
    platforms = platforms.linux;
    maintainers = [ maintainers.markuskowa ];
  };
}

