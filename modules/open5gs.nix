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

      addr = {
        mme = addr_option "mme" "127.0.0.2";
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
      ${cfg.net.addr.hss} hss.lte
      ${cfg.net.addr.mme} mme.lte
      ${cfg.net.addr.pcrf} pcrf.lte
      ${cfg.net.addr.smf} smf.lte
    '';

    nixpkgs.overlays = [ (import ../default.nix) ];
  };
}
