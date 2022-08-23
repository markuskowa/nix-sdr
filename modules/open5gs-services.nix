{ config, pkgs, lib, ... } :

with lib;

let
  cfg = config.services.open5gs;

  formatter = pkgs.formats.yaml {};

  services = [
    "hss"
    "mme"
    "sgwc"
    "sgwu"
    "smf"
    "upf"
    "pcrf"
  ];

  # Options template
  options = name: {
    enable = mkEnableOption "${name}";
    settings = mkOption {
      description = "Contents of config file";
      type = formatter.type;
      default = {};
    };
  };

  makeDefaults = mapAttrs ( name: value:
          if !(isAttrs value) then mkOptionDefault value else value
          );

  # Service template
  service = name: settings: mkIf cfg."${name}".enable {
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wants = optional (name == "hss" || name == "pcrf") "mongodb.service";

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.open5gs}/bin/open5gs-${name}d -c ${formatter.generate "${name}.yml" settings}";
      Restart = "always";
      RestartSec = 2;
      RestartPreventExitStatus = 1;
      User = "open5gs";
      Group = "open5gs";
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

in {
  options.services.open5gs = {
    hss = options "HSS";
    mme = options "MME";
    sgwc = options "SGW-C";
    smf = options "SMF/PGW-C";
    sgwu = options "SGW-U";
    upf = options "UPF/PGW-U";
    pcrf = options "PCRF";
  };

  config = {
    systemd.services = listToAttrs (map (name: nameValuePair "open5gs-${name}" (service name cfg."${name}".settings)) services);

    users = mkIf (any (x: cfg."${x}".enable) services) {
      users.open5gs = {
        isSystemUser = true;
        group = "open5gs";
      };
      groups.open5gs = {};
    };

    # HSS
    services.open5gs.hss.settings = mkIf cfg.hss.enable (makeDefaults {
      db_uri = "mongodb://localhost/open5gs";
      hss.freeDiameter = makeDiameter "hss" "mme" cfg.net.addr.hss cfg.net.addr.mme;
    });

    # MME
    services.open5gs.mme.settings = mkIf cfg.mme.enable (makeDefaults {
      mme = {
        freeDiameter = makeDiameter "mme" "hss" cfg.net.addr.mme cfg.net.addr.hss;
        s1ap = [ {addr = cfg.net.addr.mme;} ];
        gtpc = [ {addr = cfg.net.addr.mme;} ];
        gummei = {
          plmn_id = {
            mcc = cfg.net.mcc;
            mnc = cfg.net.mnc;
          };
          mme_gid = 1;
          mme_code = 1;
        };
        tai = {
          plmn_id = {
            mcc = cfg.net.mcc;
            mnc = cfg.net.mnc;
          };
          tac = 7;
        };
        security = {
            integrity_order = [ "EIA2" "EIA1" ];
            ciphering_order = [ "EEA2" "EEA1" ];
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
    });

    # SGW-C
    services.open5gs.sgwc.settings = mkIf cfg.sgwc.enable (makeDefaults {
      sgwc = {
        gtpc = [{ addr = cfg.net.addr.sgwc; }];
        pfcp = [{ addr = cfg.net.addr.sgwc; }];
      };
      sgwu.pfcp = [{ addr = cfg.net.addr.sgwu; }];
    });

    # SMF/PGW-C
    services.open5gs.smf.settings = mkIf cfg.smf.enable (makeDefaults {
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
    });

    # SGW-U
    services.open5gs.sgwu.settings = mkIf cfg.sgwu.enable (makeDefaults {
      sgwu = {
        pfcp = [{ addr = cfg.net.addr.sgwu; }];
        gtpu = [{ addr = cfg.net.addr.sgwu; }];
      };
    });

    # UPF/PGW-U
    services.open5gs.upf.settings = mkIf cfg.upf.enable (makeDefaults {
      upf = {
        pfcp = [{ addr = cfg.net.addr.upf; }];
        gtpu = [{ addr = cfg.net.addr.upf; }];
        subnet = [{
          addr = with cfg.net.gw.addr; "${address}/${toString prefixLength}";
          dev = cfg.net.gw.device;
        }];
      };
    });

    # PCRF
    services.open5gs.pcrf.settings = mkIf cfg.pcrf.enable (makeDefaults {
      db_uri = "mongodb://localhost/open5gs";
      pcrf.freeDiameter = makeDiameter "pcrf" "smf" cfg.net.addr.pcrf cfg.net.addr.smf;
    });
  };
}
