{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.srsran.enodeb;
  formatter = pkgs.formats.ini {};

in {
  ###### interface

  options.services.srsran.enodeb = {
    enable = mkEnableOption "eNodeB service";

    package = mkOption {
      description = "SRSRAN package";
      type = types.package;
      default = pkgs.srsran;
    };

    settings = mkOption {
      type = formatter.type;
      default = {};
      description = "Contents of config file";
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    services.srsran.enodeb.settings = {
      enb = {
        enb_id        = mkDefault "0x001";
        mme_addr      = mkDefault "127.0.1.100";
        gtp_bind_addr = mkDefault "127.0.1.1";
        s1c_bind_addr = mkDefault "127.0.1.1";
        s1c_bind_port = mkDefault 0;
        n_prb         = mkDefault 15;
        mcc           = mkDefault config.services.srsran.mcc;
        mnc           = mkDefault config.services.srsran.mnc;
      };

      enb_files = {
        sib_config = mkDefault "${pkgs.srsran}/share/srsran/sib.conf.example";
        rr_config  = mkDefault "${pkgs.srsran}/share/srsran/rr.conf.example";
        rb_config = mkDefault "${pkgs.srsran}/share/srsran/rb.conf.example";
      };

      rf = {
        dl_earfcn = mkDefault 1917; # 1876.7 DL, 1781.7 UL, see https://www.sqimway.com/lte_band.php
        tx_gain = mkDefault 55;
        rx_gain = mkDefault 40;

        device_name = mkDefault "soapy";
        device_args = mkDefault "driver=lime";
      };

      log = {
        all_level     = mkDefault "info";
        all_hex_limit = mkDefault 32;
        filename      = mkDefault "/var/log/enb.log";
        file_max_size = mkDefault "-1";
      };

      gui.enable = false;
    };

    systemd.services.srsran-enodeb = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" "srsran-epc.service" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/srsenb ${formatter.generate "enb.conf" cfg.settings}";
        CPUSchedulingPolicy = "rr";
        CPUSchedulingPriority = 50;
      };
    };
  };
}
