{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.open5gs;

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
      realm = mkOption {
        description = "Top level DNS domain for network";
        type = types.str;
        default = "mnc${cfg.net.mnc}.mcc${cfg.net.mcc}.3gppnetwork.org";
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

      name = {
        full = mkOption {
          description = "Full network name";
          type = types.str;
          default = "Open5GS";
        };
        short = mkOption {
          description = "Short network name";
          type = types.str;
          default = "Open5GS";
        };
      };

      addr = {
        mme = addr_option "mme" "127.0.0.2";
        sgwc = addr_option "sgwc" "127.0.0.3";
        smf = addr_option "smf" "127.0.0.4";
        sgwu = addr_option "sgwu" "127.0.0.6";
        upf = addr_option "upf" "127.0.0.7";
        hss = addr_option "hss" "127.0.0.8";
        pcrf = addr_option "pcrf" "127.0.0.9";
      };

      apns = mkOption {
        description = "Definition of APNs and its interfaces";
        type = types.listOf (types.submodule ({ config, ... }: {
          options = {
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
            dnn = mkOption {
              description = "Name of APN/DNN";
              type = with types; nullOr str;
              default = null;
            };
            range = mkOption {
              description = "IP address range.";
              type = with types; nullOr str;
              default = null;
            };
          };
        }));
        default = [{
          dnn = "internet";
          addr = { address = "10.45.0.1"; prefixLength = 24; };
          range = "10.45.0.20-10.45.0.100";
          device = "apn-internet";
        }{
          # Fallback if not DNN/APN is specifed
          # SMF/UPF crash if not UE has no APN
          addr = { address = "10.45.0.1"; prefixLength = 24; };
          range = "10.45.0.20-101.45.0.110";
          device = "apn-internet";
        }];
      };
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
      enable = mkDefault true;
      settings = {
        enb = {
          mme_addr = cfg.net.addr.mme;
          mcc = config.services.open5gs.net.mcc;
          mnc = config.services.open5gs.net.mnc;
        };
      };
    };

    networking.interfaces = listToAttrs (map (x: {
      name = x.device;
      value = {
        virtual = true;
        virtualType = "tun";
        virtualOwner = "open5gs";
        ipv4.addresses = [ x.addr ];
      };}) cfg.net.apns);

    # Make sure diameter can resolve identities
    networking.extraHosts = ''
      ${cfg.net.addr.hss} hss.epc.${cfg.net.realm}
      ${cfg.net.addr.mme} mme.epc.${cfg.net.realm}
      ${cfg.net.addr.pcrf} pcrf.epc.${cfg.net.realm}
      ${cfg.net.addr.smf} smf.epc.${cfg.net.realm}
    '';
  };
}
