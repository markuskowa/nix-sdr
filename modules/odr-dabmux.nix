{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.odr.dabmux;

  configMux = pkgs.writeText "config.mux" cfg.config;

in
{
  ###### interface

  options = {
    services.odr.dabmux = {
        enable = mkEnableOption "Opendigital Radio DAB multiplexer";

        config = mkOption {
          type = types.str;
          default = null;
          description = "Contents of config file.";
        };
      };
  };

  ###### implementation

  config = {
    systemd.services.odr-dabmux = mkIf cfg.enable {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.odrDabMux}/bin/odr-dabmux ${configMux}";
        User = "odruser";
        Group = "odrgroup";
      };
    };
  };
}

