{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.srsran.ue;
  formatter = pkgs.formats.ini {};

in {
  ###### interface

  options.services.srsran.ue = {
    enable = mkEnableOption "User equipment simulator";

    settings = mkOption {
      type = formatter.type;
      default = {};
      description = "Contents of config file";
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    services.srsran.ue.settings = {
      rf = {
        freq_offset = mkDefault 0;
        tx_gain = mkDefault 80;
      };

      "rat.eutra" = {
        dl_earfcn = mkDefault 1906;
      };

      usim = {
        mode = mkDefault "soft";
        algo = mkDefault "milenage";
        opc  = mkDefault "63BFA50EE6523365FF14C1F45F88737D";
        k    = mkDefault "00112233445566778899aabbccddeeff";
        imsi = mkDefault "001010123456780";
        imei = mkDefault "353490069873319";
      };

      log = {
        all_level     = mkDefault "info";
        phy_lib_level = "none";
        all_hex_limit = mkDefault 32;
        filename      = mkDefault "/var/log/ue.log";
        file_max_size = mkDefault "-1";
      };

      gui.enable = false;
    };

    systemd.services.srsran-ue = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.srsran}/bin/srsue ${formatter.generate "ue.conf" cfg.settings}";
      };
    };
  };
}
