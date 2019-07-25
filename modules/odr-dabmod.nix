{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.odr.dabmod;

  configMod = pkgs.writeText "config.mod" cfg.config;

in
{
  ###### interface

  options = {
    services.odr.dabmod = {
        enable = mkEnableOption "Opendigital Radio DAB modulator";

        config = mkOption {
          type = types.str;
          default = null;
          description = "Contents of config file.";
        };
      };
  };

  ###### implementation

  config = {
    systemd.services.odr-dabmod = mkIf (config.services.odr.enable && cfg.enable) {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.odrDabMod}/bin/odr-dabmmod ${configMod}";
        User = "odruser";
        Group = "odrgroup";
      };
    };
  };
}

