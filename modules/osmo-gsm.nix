{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.osmo;

  # {
  #  "log vty" = {
  #    set value
  # }

  settingsToCfg = settings:
    concatStringsSep "\n" (flatten (handleAttrs settings ""));

  handleAttrs = settings: indent:
    mapAttrsToList (name: value:
    if isAttrs value
    then [name] ++ (handleAttrs value (indent + " "))
    else map (x:
      if isAttrs x
      then handleAttrs x indent
      else x) value
    );

  formatter = {
    type = with types; let
      valueType = oneOf [
        (listOf str valueType)
        (attrsOf valueType)
      ] // {
        description = "Osmocom configuration files";
      };
    in valueType;

    generate = name: value:
      pkgs.writeText name (settingsToCfg value);
  };

  bscCfg = ''
    ! osmo-bsc default configuration
    ! (assumes STP to run on 127.0.0.1 and uses default point codes)
    !
    e1_input
     e1_line 0 driver ipa
    network
     network country code ${cfg.nitb.mcc}
     mobile network code ${cfg.nitb.mnc}
     encryption a5 0
     neci 1
     paging any use tch 0
     handover 0
     handover algorithm 1
     handover1 window rxlev averaging 10
     handover1 window rxqual averaging 1
     handover1 window rxlev neighbor averaging 10
     handover1 power budget interval 6
     handover1 power budget hysteresis 3
     handover1 maximum distance 9999
     dyn_ts_allow_tch_f 0
     ! T3212 is in units of 6min, so below we set 5 * 6 = 30min
     timer net T3212 5
     bts 0
      type osmo-bts
      band ${cfg.nitb.band}
      ipa unit-id 10 0
      cell_identity 10
      location_area_code 1
      base_station_id_code 63
      ms max power 15
      cell reselection hysteresis 4
      rxlev access min 0
      radio-link-timeout 32
      channel allocator ascending
      rach tx integer 9
      rach max transmission 7
      channel-description attach 1
      channel-description bs-pa-mfrms 5
      channel-description bs-ag-blks-res 1
      early-classmark-sending forbidden
      oml ipa stream-id 255 line 0
      codec-support fr efr amr
      gprs mode none
      trx 0
       rf_locked 0
       arfcn ${toString cfg.nitb.arfcn}
       rsl e1 tei 0
       nominal power 23
       ! to use full TRX power, set max_power_red 0
       max_power_red 20
       rsl e1 tei 0
       timeslot 0
        phys_chan_config CCCH+SDCCH4
        hopping enabled 0
       timeslot 1
        phys_chan_config SDCCH8
        hopping enabled 0
       timeslot 2
        phys_chan_config TCH/F
        hopping enabled 0
       timeslot 3
        phys_chan_config TCH/F
        hopping enabled 0
       timeslot 4
        phys_chan_config TCH/F
        hopping enabled 0
       timeslot 5
        phys_chan_config TCH/F
        hopping enabled 0
       timeslot 6
        phys_chan_config TCH/F
        hopping enabled 0
       timeslot 7
        phys_chan_config TCH/F
        hopping enabled 0
    msc 0
     no bsc-welcome-text
     no bsc-msc-lost-text
     no bsc-grace-text
     codec-list fr1
     type normal
     allow-emergency allow
     amr-config 12_2k forbidden
     amr-config 10_2k forbidden
     amr-config 7_95k forbidden
     amr-config 7_40k forbidden
     amr-config 6_70k forbidden
     amr-config 5_90k allowed
     amr-config 5_15k forbidden
     amr-config 4_75k forbidden
     mgw remote-ip 127.0.0.1
     mgw remote-port 2427
     mgw local-port 2727
    bsc
     mid-call-timeout 0
    cbc
     no remote-ip
     no listen-port
  '';

  mscCfg = ''
    line vty
     no login
    !
    stats interval 5
    !
    network
     network country code ${cfg.nitb.mcc}
     mobile network code ${cfg.nitb.mnc}
     short name ${cfg.nitb.nameShort}
     long name ${cfg.nitb.nameShort}
     encryption a5 0 1 3
     authentication ${if cfg.nitb.requireAuth then "required" else "optional"}
     rrlp mode none
     mm info 1
    msc
     mgw remote-ip 127.0.0.1
     mgw remote-port 2427
     mgw local-port 2728
     assign-tmsi
     check-imei-rqd early
     auth-tuple-max-reuse-count 3
     auth-tuple-reuse-on-error 1
     ${optionalString cfg.nitb.enableSIP "mncc external /tmp/msc_mncc"}
    smsc
     database /var/lib/osmo-msc/sms.db
  '';

  hlrCfg = ''
    line vty
     bind 127.0.0.1
    ctrl
     bind 127.0.0.1
    hlr
     database ${cfg.nitb.databasePath}
     ${optionalString cfg.nitb.subscriberCreateOnDemand "subscriber-create-on-demand 5 none"}
     store-imei
     gsup
      bind ip 127.0.0.1
     ussd route prefix *#100# internal own-msisdn
     ussd route prefix *#101# internal own-imsi
  '';

  mgwCfg = ''
    mgcp
      bind ip 127.0.0.1
      rtp port-range 4002 16000
      rtp bind-ip 127.0.0.1
      rtp ip-probing
      rtp ip-dscp 46
      bind port 2427
      sdp audio payload number 98
      sdp audio payload name GSM
      number endpoints 512
      loop 0
      force-realloc 1
      rtcp-omit
      rtp-patch ssrc
      rtp-patch timestamp
  '';

  stpCfg = ''
    cs7 instance 0
     xua rkm routing-key-allocation dynamic-permitted
     listen m3ua 2905
      accept-asp-connections dynamic-permitted
  '';

  sipCfg = ''
    app
    mncc
      socket-path /tmp/msc_mncc
    sip
      local 127.0.0.1 7060
      remote 127.0.0.1 5060
  '';

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
  };

  config = mkIf cfg.nitb.enable {

    services.osmo =  {
      bsc.enable = true;
      bsc.cfg = mkDefault bscCfg;
      msc.enable = true;
      msc.cfg = mkDefault mscCfg;
      hlr.enable = true;
      hlr.cfg = mkDefault hlrCfg;
      mgw.enable = true;
      mgw.cfg = mkDefault mgwCfg;
      stp.enable = true;
      stp.cfg = mkDefault stpCfg;
      sip-connector.enable = cfg.nitb.enableSIP;
      sip-connector.cfg = mkDefault sipCfg;
    };
  };
}
