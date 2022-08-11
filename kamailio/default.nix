{ lib, stdenv, fetchFromGitHub
, flex, bison, autoconf, pkg-config, which
, openssl, curl, libxml2, pcre, libmysqlclient
} :

stdenv.mkDerivation rec {
  pname = "kamailio";
  version = "5.6.1";

  src = fetchFromGitHub {
    owner = "kamailio";
    repo = "kamailio";
    rev = version;
    sha256 = "sha256-r6EoH+xmcUQ0DVGOGiOEob39mtj2DEkhyG1Q8jfG0kI=";
  };

  nativeBuildInputs =  [ flex bison autoconf pkg-config which ];
  buildInputs = [ openssl curl libxml2 pcre libmysqlclient ];

  enableParallelBuilds = true;

  configurePhase = ''
    make include_modules="db_mysql dialplan tls" cfg
  '';

  makeFlags = [ "all" ];

  preInstall = ''
    makeFlagsArray+=(PREFIX="$out")
  '';

  meta = with lib; {
    description = "Open Source SIP Server";
    homepage = "https://kamailio.org";
    license = licenses.gpl2Only;
  };
}
