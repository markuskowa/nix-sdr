{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.srsran.epc;
  formatter = pkgs.formats.ini {};

in {
  ###### interface

  options.services.srsran.epc = {
    enable = mkEnableOption "EPC service";

    settings = mkOption {
      type = formatter.type;
      default = {};
      description = "Contents of config file";
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    services.srsran.epc.settings = {
      mme = {
        mme_code        = mkDefault "0x01";
        mme_group       = mkDefault "0x0001";
        tac             = mkDefault "0x0007";
        mcc             = config.services.srsran.mcc;
        mnc             = config.services.srsran.mnc;
        mme_bind_addr   = mkDefault "127.0.1.100";
        apn             = mkDefault "srsapn";
        dns_addr        = mkDefault "8.8.8.8";
        encryption_algo = mkDefault "EEA0";
        integrity_algo  = mkDefault "EIA1";
        paging_timer    = mkDefault 2;
        request_imeisv  = mkDefault "false";
      };

      hss.db_file = mkDefault "/var/lib/srsran";

      spgw = {
        gtpu_bind_addr   = mkDefault "127.0.1.100";
        sgi_if_addr      = mkDefault "172.16.0.1";
        sgi_if_name      = mkDefault "srs_spgw_sgi";
        max_paging_queue = mkDefault "100";
      };

      log = {
        all_level     = mkDefault "info";
        all_hex_limit = mkDefault 32;
        filename      = mkDefault "/var/log/epc.log";
      };
    };

    systemd.services.srsran-epc = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.srsran}/bin/srsepc ${formatter.generate "epc.conf" cfg.settings}";
      };
    };
  };
}
