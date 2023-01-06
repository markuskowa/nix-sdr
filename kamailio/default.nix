{ lib, stdenv, fetchFromGitHub, makeWrapper
, flex, bison, autoconf, pkg-config, which
, gnugrep, gawk, coreutils
, openssl, curl, libxml2, pcre, libmysqlclient
, libmnl
, lksctp-tools
} :

stdenv.mkDerivation rec {
  pname = "kamailio";
  version = "5.6.2";

  src = fetchFromGitHub {
    owner = "kamailio";
    repo = "kamailio";
    rev = version;
    sha256 = "sha256-jxFAc1PRGcQKEBy8I+YIGtLMGXEkOEPoWmY66bdn4Pg=";
  };

  nativeBuildInputs = [
    flex
    bison
    autoconf
    pkg-config
    which
    makeWrapper
  ];

  buildInputs = [
    openssl
    curl
    libxml2
    pcre
    libmysqlclient
    # IPsec
    libmnl
    lksctp-tools
  ];

  enableParallelBuilding = true;

  configurePhase = ''
    #make include_modules="db_mysql dialplan tls" cfg
    make include_modules="outbound acc registrar usrloc auth_db cdp cdp_avp db_mysql dialplan ims_auth ims_charging ims_dialog ims_diameter_server ims_icscf ims_ipsec_pcscf ims_isc ims_ocs ims_qos ims_registrar_pcscf ims_registrar_scscf ims_usrloc_pcscf ims_usrloc_scscf outbound presence presence_conference presence_dialoginfo presence_mwi presence_profile presence_reginfo presence_xml pua pua_bla pua_dialoginfo pua_reginfo pua_rpc pua_usrloc pua_xmpp sctp tls utils xcap_client xcap_server xmlops xmlrpc" cfg
  '';

  makeFlags = [ "all" ];

  preInstall = ''
    makeFlagsArray+=(PREFIX="$out")
  '';

  postFixup = ''
    wrapProgram $out/bin/kamctl \
      --set EGREP "${gnugrep}/bin/egrep" \
      --set AWK "${gawk}/bin/awk" \
      --set MD5 "${coreutils}/bin/md5sum" \
      --set LAST_LINE "${coreutils}/bin/tail" \
      --set EXPR "${coreutils}/bin/expr"
  '';

  meta = with lib; {
    description = "Open Source SIP Server";
    homepage = "https://kamailio.org";
    license = licenses.gpl2Only;
  };
}
