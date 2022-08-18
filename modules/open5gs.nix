{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.open5gs;

  formatter = pkgs.formats.yaml {};

  # Options template
  options = name: defaults: {
    enable = mkEnableOption "${name}";
    settings = mkOption {
      description = "Contents of config file";
      type = formatter.type;
      default = defaults;
    };
  };

  makeDiameter = name: peer: listen: peerIp: pkgs.writeText "${name}.conf" ''
    Identity = "${name}.lte";
    Realm = "lte";
    ListenOn = "${listen}";
    NoRelay;
    TLS_Cred = "/var/lib/open5gs/${name}.cert.pem", "/var/lib/open5gs/${name}.key.pem";
    TLS_CA = "/var/lib/open5gs/cacert.pem";

    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dbg_msg_dumps.fdx" : "0x8888";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_rfc5777.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_mip6i.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_nasreq.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_nas_mipv6.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_dcca.fdx";
    LoadExtension = "${pkgs.open5gs}/lib/freeDiameter/dict_dcca_3gpp.fdx";
    ConnectPeer = "${peer}.lte" { ConnectTo = "${peerIp}"; };
  '';

  addr_option = name: def: mkOption {
    type = with types; str;
    description = "${name} nodes";
    default = def;
  };

  addr2conf = map (x: { addr = x; } );

in {

  options.services.open5gs = {
    nitb.enable = mkEnableOption "Open5GS NITB";

    net = {
      mmc = mkOption {
        description = "Mobile Country Code";
        type = types.str;
        default = "001";
      };
      mnc = mkOption {
        description = "Mobile Network Code";
        type = types.str;
        default = "01";
      };

      addr = {
        mme = addr_option "hss" "127.0.0.2";
        sgwc = addr_option "sgwc" "127.0.0.3";
        smf = addr_option "smf" "127.0.0.4";
        sgwu = addr_option "sgwu" "127.0.0.6";
        upf = addr_option "upf" "127.0.0.7";
        hss = addr_option "hss" "127.0.0.8";
        pcrf = addr_option "pcrf" "127.0.0.9";
      };

      gw = {
        addr = mkOption {
          description = "networking.interaces.dev.addresses.ipv4 compatible set for the gateway interface";
          type = with types; attrs;
          default = { address = "10.45.0.1"; prefixLength = 16; };
        };
        device = mkOption {
          description = "TUN device for gateway";
          type = types.str;
          default = "ogstun1";
        };
      };
    };

    hss = options "hss" {
      db_uri = "mongodb://localhost/open5gs";
      logger.file = "/var/log/hss.log";
      hss.freeDiameter = makeDiameter "hss" "mme" cfg.net.addr.hss cfg.net.addr.mme;
    };

    mme = options "mme" {
      logger.file = "/var/log/mme.log";
      mme = {
        freeDiameter = makeDiameter "mme" "hss" cfg.net.addr.mme cfg.net.addr.hss;
        s1ap = [ {addr = cfg.net.addr.mme;} ];
        gtpc = [ {addr = cfg.net.addr.mme;} ];
        gummei = {
          plmn_id = {
            mcc = cfg.net.mmc;
            mnc = cfg.net.mnc;
          };
          mme_gid = 1;
          mme_code = 1;
        };
        tai = {
          plmn_id = {
            mcc = cfg.net.mmc;
            mnc = cfg.net.mnc;
          };
          tac = 7;
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
      sgwc.gtpc = [{addr = cfg.net.addr.sgwc;}];
      smf.gtpc = [{addr = cfg.net.addr.smf;}];
      metrics = {
        addr = cfg.net.addr.mme;
        port = "9090";
      };
    };

    sgwc = options "sgwc" {
      logger.file = "/var/log/sgwc.log";
      sgwc = {
        gtpc = [{ addr = cfg.net.addr.sgwc; }];
        pfcp = [{ addr = cfg.net.addr.sgwc; }];
      };
      sgwu.pfcp = [{ addr = cfg.net.addr.sgwu; }];
    };

    # SMF/PGW-C
    smf = options "smf" {
      logger.file = "/var/log/smf.log";
      smf = {
        sbi = [{ addr = cfg.net.addr.smf; port = 7777; }];
        pfcp = [{ addr = cfg.net.addr.smf; }];
        gtpc = [{ addr = cfg.net.addr.smf; }];
        gtpu = [{ addr = cfg.net.addr.smf; }];
        subnet = [{ addr = with cfg.net.gw.addr; "${address}/${toString prefixLength}"; }];
        dns = [ "8.8.8.8" "8.8.4.4" ];
        mtu = 1400;
        ctf.enabled = "auto";
        freeDiameter = makeDiameter "smf" "pcrf" cfg.net.addr.smf cfg.net.addr.pcrf;
      };

      upf.pfcp = [{ addr = cfg.net.addr.upf; }];

      metrics = {
        addr = cfg.net.addr.smf;
        port = "9090";
      };
    };

    sgwu = options "sgwu" {
      logger.file = "/var/log/sgwu.log";
      sgwu = {
        pfcp = [{ addr = cfg.net.addr.sgwu; }];
        gtpu = [{ addr = cfg.net.addr.sgwu; }];
      };
    };

    # UPF/PGW-U
    upf = options "upf" {
      logger.file = "/var/log/upf.log";
      upf = {
        pfcp = [{ addr = cfg.net.addr.upf; }];
        gtpu = [{ addr = cfg.net.addr.upf; }];
        subnet = [{
          addr = with cfg.net.gw.addr; "${address}/${toString prefixLength}";
          dev = cfg.net.gw.device;
        }];
      };
    };

    pcrf = options "pcrf" {
      db_uri = "mongodb://localhost/open5gs";
      logger.file = "/var/log/pcrf.log";
      pcrf.freeDiameter = makeDiameter "pcrf" "smf" cfg.net.addr.pcrf cfg.net.addr.smf;
    };
  };

  imports = [ ./open5gs-services.nix ];

  config = mkIf cfg.nitb.enable {

    # Subscriber DB
    services.mongodb.enable = true;

    # Setup EPC
    services.open5gs = {
      hss.enable = true;
      mme.enable = true;
      sgwc.enable = true;
      sgwu .enable = true;
      smf.enable = true;
      upf.enable = true;
      pcrf.enable = true;
    };

    # Setup SRSRAN eNodeB
    services.srsran.enodeb = {
      enable = true;
      settings = {
        enb.mme_addr = cfg.net.addr.mme;
      };
    };

    networking.interfaces."${cfg.net.gw.device}" = {
      virtual = true;
      virtualType = "tun";
      ipv4.addresses = [ cfg.net.gw.addr ];
    };

    # Make sure diameter can resolve identities
    networking.extraHosts = ''
      127.0.0.1 hss.lte
      127.0.0.1 mme.lte
      127.0.0.1 pcrf.lte
      127.0.0.1 smf.lte
    '';

    nixpkgs.overlays = [ (import ../default.nix) ];
  };
}
