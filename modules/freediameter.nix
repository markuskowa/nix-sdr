{ config, pkgs, lib, ... } :

with lib;

let
  cfg = config.services.freediameter;
  mlib = import ./lib.nix pkgs lib;


in {

  options = {
    services.freediameter = {
      enable = mkEnableOption "freeDiameter service";
      config = mlib.freediameterModule;
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.freediameter = {
        isSystemUser = true;
        group = "freediameter";
      };
      groups.freediameter = {};
    };

    systemd.services.freediameter = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.free-diameter}/bin/freeDiameterd -c ${mlib.makeDiameterConf "freeDiameterd" "${pkgs.free-diameter}/lib/freeDiameter" cfg.config}";
        Restart = "always";
        RestartSec = 2;
        RestartPreventExitStatus = 1;
        User = "freediameter";
        Group = "freediameter";
      };
    };
  };
}
