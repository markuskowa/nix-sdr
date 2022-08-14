{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.open5gs;

  formatter = pkgs.formats.yaml {};

  # Service template
  service = name: settings: mkIf cfg."${name}".enable {
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.open5gs}/bin/open5gs-${name}d -c ${formatter.generate "${name}.yml" settings}";
    };
  };

  # Options template
  options = name: defaults: {
    enable = mkEnableOption "${name}";
    settings = mkOption {
      description = "Contents of config file";
      type = formatter.type;
      default = defaults;
    };
  };

  genCerts = pkgs.writeScriptBin "genCerts" ''
    ${pkgs.openssl}/bin/openssl rand -out rnd -hex 256

    mkdir demoCA
    echo 01 > demoCA/serial
    touch demoCA/index.txt.attr
    touch demoCA/index.txt

    # CA self certificate
    ${pkgs.openssl}/bin/openssl req -new -batch -x509 -days 3650 -nodes -newkey rsa:1024 -out /run/cacert.pem -keyout /run/cakey.pem -subj /CN=${config.networking.hostName}ca/C=KO/ST=Seoul/L=Nowon/O=Open5GS/OU=Tests

    for i in nitb; do
      ${pkgs.openssl}/bin/openssl genrsa -out /run/$i.key.pem 1024
      ${pkgs.openssl}/bin/openssl req -new -batch -out /run/$i.csr.pem -key /run/$i.key.pem -subj /CN=${config.networking.hostName}/C=KO/ST=Seoul/L=Nowon/O=Open5GS/OU=Tests
      ${pkgs.openssl}/bin/openssl ca -cert /run/cacert.pem -days 3650 -keyfile /run/cakey.pem -in /run/$i.csr.pem -out /run/$i.cert.pem -outdir /run -batch
    done
  '';

  makeDiameter = name: peer: listen: peerIp: pkgs.writeText "${name}.conf" ''
    Identity = "${config.networking.hostName}";
    Realm = "localdomain";
    ListenOn = "${listen}";
    NoRelay;
    TLS_Cred = "/run/nitb.cert.pem", "/run/nitb.key.pem";
    TLS_CA = "/run/cacert.pem";

    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dbg_msg_dumps.fdx" : "0x8888";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_rfc5777.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_mip6i.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_nasreq.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_nas_mipv6.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_dcca.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_dcca_3gpp.fdx";
    ConnectPeer = "${config.networking.hostName}" { ConnectTo = "${peerIp}"; No_TLS; };
  '';

  services = [
    "hss"
    "mme"
    "sgwc"
    "sgwu"
    "smf"
    "upf"
    "pcrf"
  ];
in {

  options.services.open5gs = {
    nitb.enable = mkEnableOption "Open5GS NITB";

    hss = options "hss" {
      db_uri = "mongodb://localhost/open5gs";
      logger.file = "/var/log/hss.log";
      hss.freeDiameter = makeDiameter "hss" "mme" "127.0.0.8" "127.0.0.2";
    };

    mme = options "mme" {
      logger.file = "/var/log/mme.log";
      mme = {
        freeDiameter = makeDiameter "mme" "hss" "127.0.0.2" "127.0.0.8";
        s1ap = [ {addr = "127.0.0.2";} ];
        gtpc = [ {addr = "127.0.0.2";} ];
        gummei = {
          plmn_id = {
            mcc = "001";
            mnc = "01";
          };
          mme_gid = 1;
          mme_code = 1;
        };
        tai = {
          plmn_id = {
            mcc = "001";
            mnc = "01";
          };
          tac = 1;
        };
        security = {
            integrity_order = [ "EIA2" "EIA1" "EIA0" ];
            ciphering_order = [ "EEA0" "EEA1" "EEA2" ];
        };
        network_name = {
            full = "Open5GS";
        };
        mme_name = "open5gs-mme1";
      };
      sgwc.gtpc = [{addr = "127.0.0.3";}];
      smf.gtpc = [{addr = "127.0.0.4";}];
      metrics = {
        addr = "127.0.0.2";
        port = "9090";
      };
    };

    sgwc = options "sgwc" {
      logger.file = "/var/log/sgwc.log";
      sgwc = {
        gtpc = [{ addr = "127.0.0.3"; }];
        pfcp = [{ addr = "127.0.0.3"; }];
      };
      sgwu.pfcp = [{ addr = "127.0.0.6"; }];
    };

    # SMF/PGW-C
    smf = options "smf" {
      logger.file = "/var/log/smf.log";
      smf = {
        sbi = [{ addr = "127.0.0.4"; port = 7777; }];
        pfcp = [{ addr = "127.0.0.4"; }];
        gtpc = [{ addr = "127.0.0.4"; }];
        gtpu = [{ addr = "127.0.0.4"; }];
        subnet = [{ addr = "10.45.0.1/16"; }];
        dns = [ "8.8.8.8" "8.8.4.4" ];
        mtu = 1400;
        ctf.enabled = "auto";
        freeDiameter = makeDiameter "smf" "pcrf" "127.0.0.4" "127.0.0.9";
      };

      # nrf.sbi = [{ addr = "127.0.0.10"; port = 7777; }];
      upf.pfcp = [{ addr = "127.0.0.7"; }];

      metrics = {
        addr = "127.0.0.4";
        port = "9090";
      };
    };

    sgwu = options "sgwu" {
      logger.file = "/var/log/sgwu.log";
      sgwu = {
        pfcp = [{ addr = "127.0.0.6"; }];
        gtpu = [{ addr = "127.0.0.6"; }];
      };
    };

    # UPF/PGW-U
    upf = options "upf" {
      logger.file = "/var/log/upf.log";
      upf = {
        pfcp = [{ addr = "127.0.0.7"; }];
        gtpu = [{ addr = "127.0.0.7"; }];
        subnet = [{ addr = "10.45.0.1/16"; }];
      };
    };

    pcrf = options "pcrf" {
      db_uri = "mongodb://localhost/open5gs";
      logger.file = "/var/log/pcrf.log";
      pcrf.freeDiameter = makeDiameter "pcrf" "smf" "127.0.0.9" "127.0.0.4";
    };
  };

  config = mkIf cfg.nitb.enable {
    services.mongodb.enable = true;

    systemd.services = listToAttrs (map (name: nameValuePair "open5gs-${name}" (service name cfg."${name}".settings)) services);

    services.open5gs = {
      hss.enable = true;
      mme.enable = true;
      sgwc.enable = true;
      sgwu .enable = true;
      smf.enable = true;
      upf.enable = true;
      pcrf.enable = true;
    };

    environment.systemPackages = [ genCerts ];
    nixpkgs.overlays = [ (import ../default.nix) ];
  };
}
