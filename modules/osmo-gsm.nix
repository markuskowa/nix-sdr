{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.osmo;
  mlib = import ./lib.nix pkgs lib;

in {

  imports = [ ./osmo-service.nix ];

  options.services.osmo = {
    nitb = {
      enable = mkEnableOption "Osmocom GSM NITB";

      band = mkOption {
        description = "GSM Frequency band";
        type = with types; enum [ "GSM900" "DCS1800" "PCS1900" ];
        default = "DCS1800";
      };

      arfcn = mkOption {
        description = "Frequency code (see https://www.sqimway.com/gsm_arfcn.php)";
        type = types.int;
        default = 864; # 1875.6 DL, 1780.6 UL
      };

      maxPowerReduction = mkOption {
        description = "Reduce maximum power by N dB";
        type = types.ints.unsigned;
        default = 20;
      };

      multiArfcn = mkOption {
        description = "Use osmo-trx's multiArfcn mode";
        type = types.ints.between 1 3;
        default = 1;
      };

      mcc = mkOption {
        description = "Mobile Country Code";
        type = types.str;
        default = "001";
      };

      mnc = mkOption {
        description = "Mobile Network Code";
        type = types.str;
        default = "01";
      };

      nameShort = mkOption {
        description = "Short network name";
        type = types.str;
        default = "Osmo";
      };

      nameLong = mkOption {
        description = "Long network name";
        type = types.str;
        default = "Osmo";
      };

      subscriberCreateOnDemand = mkOption {
        description = "Create IMSI subscriber entry on demand in HLR register";
        type = types.bool;
        default = false;
      };

      requireAuth = mkOption {
        description = "Require authentication";
        type = types.bool;
        default = true;
      };

      databasePath = mkOption {
        description = "Path to HLR database";
        type = types.str;
        default = "/var/lib/osmo-hlr/hlr.db";
      };

      enableGPRS = mkEnableOption "GRPS/EDGE data service";
      GPRSType = mkOption {
        description = "GPRS or EDGE";
        type = with types; enum [ "gprs" "egprs" ];
        default = "grps";
      };

      apn-addr = mkOption {
        description = "Subnet for GRPS access point";
        type = types.attrs;
        default = { address = "10.46.1.1"; prefixLength = 24; };
      };

      enableSIP = mkEnableOption "SIP connector";
    };

    sip-connector = {
      enable = mkEnableOption "osmo-sip-connector";
      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = {
          app = {};
          mncc.socket-path = "/tmp/msc_mncc";
          sip = {
            local = "127.0.0.1 7060";
            remote = "127.0.0.1 5060";
          };
        };
      };
    };

    stp = {
      enable = mkEnableOption "osmo-stp";
      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = {
          "cs7 instance 0" = {
            "xua rkm routing-key-allocation" = "dynamic-permitted";
            "listen m3ua 2905" = {
              "accept-asp-connections" = "dynamic-permitted";
            };
          };
        };
      };
    };

    mgw = {
      enable = mkEnableOption "osmo-mgw";
      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = {
          mgcp = {
            "bind ip" = "127.0.0.1";
            "bind port" = 2427;
            "rtp port-range" = "4002 16000";
            "rtp bind-ip" = "127.0.0.1";
            "rtp ip-probing" = "";
            "rtp ip-dscp" = 46;
            "sdp audio payload number" = 98;
            "sdp audio payload name" = "GSM";
            "number endpoints" = 64;
            "force-realloc" = 1;
            "rtcp-omit" = "";
            "rtp-patch ssrc" = "";
            "rtp-patch timestamp" = "";
          };
        };
      };
    };

    hlr = {
      enable = mkEnableOption "osmo-hlr";
      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = {
          hlr = {
            database = cfg.nitb.databasePath;
            subscriber-create-on-demand = mkIf cfg.nitb.subscriberCreateOnDemand "5 none";
            store-imei = "";
            gsup."bind ip" = "127.0.0.1";
            "ussd route prefix *#100#" = "internal own-msisdn";
            "ussd route prefix *#101#" = "internal own-imsi";
          };
        };
      };
    };

    msc = {
      enable = mkEnableOption "osmo-msc";
      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = {
          network = {
            "network country code" = cfg.nitb.mcc;
            "mobile network code" = cfg.nitb.mnc;
            "short name" = cfg.nitb.nameShort;
            "long name" = cfg.nitb.nameShort;
            encryption = "a5 0 1 3";
            authentication = if cfg.nitb.requireAuth then "required" else "optional";
            "rrlp mode" = "none";
            "mm info" = 1;
          };
          msc = {
            "mgw remote-ip" = "127.0.0.1";
            "mgw remote-port" = 2427;
            "mgw local-port" = 2728;
            assign-tmsi = "";
            check-imei-rqd = "early";
            auth-tuple-max-reuse-count = 3;
            auth-tuple-reuse-on-error = 1;
            "mncc external" = mkIf cfg.nitb.enableSIP "/tmp/msc_mncc";
          };
          smsc.database = "/var/lib/osmo-msc/sms.db";
        };
      };
    };

    bsc = {
      enable = mkEnableOption "osmo-bsc";
      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = with mlib.osmo-formatter; {
          e1_input."e1_line 0" = "driver ipa";
          network = mkPrio 254 {
            "network country code" = mkPrio 1 cfg.nitb.mcc;
            "mobile network code" =  mkPrio 2 cfg.nitb.mnc;
            encryption = mkPrio 3 "a5 0 1 3";
            neci = mkPrio 4 1;
            handover =  mkPrio 5 0;
            "bts 0" = {
              type = mkPrio 10 "osmo-bts";
              band = cfg.nitb.band;
              "ipa unit-id" = "10 0";
              cell_identity = 10;
              location_area_code = 1;
              base_station_id_code = 63;
              "ms max power" = 15;
              "cell reselection hysteresis" = 4;
              "rxlev access min" = 0;
              "channel allocator" = "ascending";
              "rach tx integer" = 9;
              "rach max transmission" = 7;
              "oml ipa stream-id" = "255 line 0";
              "gprs mode" = mkPrio 256 (if cfg.nitb.enableGPRS then cfg.nitb.GPRSType else "none");
              "gprs routing area" = mkIf cfg.nitb.enableGPRS (mkPrio 257 1);
              "gprs cell bvci" = mkIf cfg.nitb.enableGPRS (mkPrio 257 2);
              "gprs nsei" = mkIf cfg.nitb.enableGPRS (mkPrio 257 1);
              "gprs nsvc 0 nsvci" = mkIf cfg.nitb.enableGPRS (mkPrio 257 1);
              "gprs nsvc 0 local udp port" = mkIf cfg.nitb.enableGPRS (mkPrio 257 23001);
              "gprs nsvc 0 remote udp port" = mkIf cfg.nitb.enableGPRS (mkPrio 257 23000);
              "gprs nsvc 0 remote ip" = mkIf cfg.nitb.enableGPRS (mkPrio 257 "127.0.0.1");
            } // listToAttrs (map (n: { name = "trx ${toString n}"; value = mkPrio 258 {
                   rf_locked = 0;
                   arfcn = cfg.nitb.arfcn + n * 4;
                   "rsl e1 tei" = 0;
                   "nominal power" = 23;
                   max_power_red = cfg.nitb.maxPowerReduction;
                   "timeslot 0" = {
                     phys_chan_config = "CCCH+SDCCH4";
                     "hopping enabled" = 0;
                   };
                   "timeslot 1" = {
                     phys_chan_config = "SDCCH8";
                     "hopping enabled" = 0;
                   };
                   "timeslot 2" = {
                     phys_chan_config = "TCH/F";
                     "hopping enabled" = 0;
                   };
                   "timeslot 3" = {
                     phys_chan_config = "TCH/F";
                     "hopping enabled" = 0;
                   };
                   "timeslot 4" = {
                     phys_chan_config = "TCH/F" + optionalString cfg.nitb.enableGPRS "_PDCH";
                     "hopping enabled" = 0;
                   };
                   "timeslot 5" = {
                     phys_chan_config = "TCH/F" + optionalString cfg.nitb.enableGPRS "_PDCH";
                     "hopping enabled" = 0;
                   };
                   "timeslot 6" = {
                     phys_chan_config = "TCH/F" + optionalString cfg.nitb.enableGPRS "_PDCH";
                     "hopping enabled" = 0;
                   };
                   "timeslot 7" = {
                     phys_chan_config = "TCH/F" + optionalString cfg.nitb.enableGPRS "_PDCH";
                     "hopping enabled" = 0;
                   };
                  };}) (genList (x: x) cfg.nitb.multiArfcn));
          };
          "msc 0" = {
            codec-list = "fr1";
            allow-emergency = "allow";
            "amr-config 12_2k" = "forbidden";
            "amr-config 10_2k" = "forbidden";
            "amr-config 7_95k" = "forbidden";
            "amr-config 7_40k" = "forbidden";
            "amr-config 6_70k" = "forbidden";
            "amr-config 5_90k" = "allowed";
            "amr-config 5_15k" = "forbidden";
            "amr-config 4_75k" = "forbidden";
            "mgw remote-ip" = "127.0.0.1";
            "mgw remote-port" =  "2427";
            "mgw local-port" = "2727";
          };
          bsc = {
            mid-call-timeout = 0;
          };
        };
      };
    };

    pcu = {
      enable = mkEnableOption "osmo-pcu";
      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = {
          pcu = {
            flow-control-interval = 10;
            cs = 2;
            "cs max" = 4;
            mcs = 2;
            "mcs max" = 9;
            alloc-algorithm = "dynamic";
            gamma = 0;
          };
        };
      };
    };

    sgsn = {
      enable = mkEnableOption "osmo-sgsn";
      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = with mlib.osmo-formatter; {
          ns = {
            "bind udp local" = {
              listen = "127.0.0.1 23000";
              accept-ipaccess = "";
            };
          };
          sgsn = {
            "gtp local-ip" = "127.0.0.1";
            "gtp state-dir" = "/var/lib/osmo-sgsn";
            "ggsn 0 remote-ip" = mkPrio 256 "127.0.0.2";
            "ggsn 0 gtp-version" = mkPrio 256 1;
            "ggsn 0 echo-interval" = mkPrio 256 60;
            # "apn * ggsn" = mkPrio 257 "ggsn0";
            # "encryption uea" = "0 1 2";
            # "encryption gea" = "0";
            auth-policy = "accept-all";
            # "compression rfc1144" = "passive";
            # "compression v42bis" = "passive";
          };
          bssgp = {};
        };
      };
    };

    ggsn = {
      enable = mkEnableOption "osmo-ggsn";
      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = {
          "ggsn ggsn0" = {
            "gtp state-dir" = "/var/lib/osmo-ggsn";
            "gtp bind-ip" = "127.0.0.2";
            "apn internet" = {
              gtpu-mode = "tun";
              tun-device = "apn-internet";
              "ip prefix" = "dynamic ${cfg.nitb.apn-addr.address + "/" + toString cfg.nitb.apn-addr.prefixLength}";
              "ip dns 1" = head config.networking.nameservers;
              "ip dns 0" = cfg.nitb.apn-addr.address;
            };
          };
        };
      };
    };

    bts = {
      enable = mkEnableOption "osmo-bts";
      backend = mkOption {
        description = "virtual or trx";
        type = with types; enum [ "virtual" "trx" ];
        default = "virtual";
      };

      cfgTrx = mkOption {
        description = "Contents of osmo-trx config file";
        type = with types; nullOr str;
        default = null;
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = mlib.osmo-formatter.type;
        };
        default = with mlib.osmo-formatter; {
          "phy 0" = mkPrio 1 {
            instance = 0;
            "osmotrx ip local" = "127.0.0.253";
            "osmotrx ip remote" = "127.0.0.254";
          };
          "bts 0" = mkPrio 2 {
            band = mkPrio 1 cfg.nitb.band;
            "ipa unit-id" = mkPrio 2 "10 0";
            "oml remote-ip" = mkPrio 3 "127.0.0.1";
            "gsmtap-sapi ccch" = "";
            "gsmtap-sapi pdtch" = "";
            "trx 0" = {
              "phy 0 instance 0" = "";
            };
          };
        };
      };
    };
  };


  config = mkIf cfg.nitb.enable {
    networking = {
      interfaces.apn-internet = mkIf cfg.nitb.enableGPRS {
        virtual = true;
        virtualType = "tun";
        virtualOwner = "osmo";
        ipv4.addresses = [ cfg.nitb.apn-addr ];
      };
    };

    services.osmo =  {
      bts.enable = mkDefault true;
      bsc.enable = true;
      msc.enable = true;
      hlr.enable = true;
      mgw.enable = true;
      stp.enable = true;
      pcu.enable = cfg.nitb.enableGPRS;
      sgsn.enable = cfg.nitb.enableGPRS;
      ggsn.enable = cfg.nitb.enableGPRS;
      sip-connector.enable = cfg.nitb.enableSIP;
    };
  };
}
