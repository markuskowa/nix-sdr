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
          mncc = { socket-path = "/tmp/msc_mncc"; };
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
        default = {
          e1_input."e1_line 0" = "driver ipa";
          network = {
            "network country code" = cfg.nitb.mcc;
            "mobile network code" = cfg.nitb.mnc;
            encryption = "a5 0 1 3";
            neci = 1;
            handover = 0;
            "bts 0" = {
              type = x: "osmo-bts";
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
              "gprs mode" = "none";
            } // listToAttrs (map (n: { name = "trx ${toString n}"; value = {
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
                     phys_chan_config = "TCH/F";
                     "hopping enabled" = 0;
                   };
                   "timeslot 5" = {
                     phys_chan_config = "TCH/F";
                     "hopping enabled" = 0;
                   };
                   "timeslot 6" = {
                     phys_chan_config = "TCH/F";
                     "hopping enabled" = 0;
                   };
                   "timeslot 7" = {
                     phys_chan_config = "TCH/F";
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
  };

  config = mkIf cfg.nitb.enable {

    services.osmo =  {
      bsc.enable = true;
      msc.enable = true;
      hlr.enable = true;
      mgw.enable = true;
      stp.enable = true;
      sip-connector.enable = cfg.nitb.enableSIP;
    };
  };
}
