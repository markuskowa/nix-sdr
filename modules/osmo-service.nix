{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.osmo;

  # Service template
  service = name: settings: mkIf cfg."${name}".enable {
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs."osmo-${name}"}/bin/osmo-${name} -c ${pkgs.writeText "${name}.cfg" settings}";
      Restart = "always";
      RestartSec = 2;
      User = "osmo";
      Group = "osmo";
      StateDirectory = "osmo-${name}";
    };
  };

  # Options template
  options = name: {
    enable = mkEnableOption "${name}";
    cfg = mkOption {
      description = "Contents of config file";
      type = types.str;
      default = "";
    };
  };

  services = [
    "bsc"
    "msc"
    "hlr"
    "stp"
    "mgw"
    "stp"
    "cbc"
    "pcu"
    "sgsn"
    "ggsn"
  ];

in {
  options.services.osmo = {
    bts = {
      enable = mkEnableOption "Osmocom BTS";

      backend = mkOption {
        description = "virtual or trx";
        type = with types; enum [ "virtual" "trx" ];
        default = "virtual";
      };

      cfg = mkOption {
        description = "Contents of config file";
        type = types.str;
        default = null;
      };

      cfgTrx = mkOption {
        description = "Contents of osmo-trx config file";
        type = types.str;
        default = null;
      };
    };
  } // listToAttrs (map (s: nameValuePair s (options s)) services);

  config = {
    systemd.services = {
      osmo-trx = mkIf (cfg.bts.enable && cfg.bts.backend == "trx") {
        wantedBy = [ "multi-user.target" ];
        requires = [ "network-online.target" ];
        after = [ "network-online.target" "osmo-bts.service" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-trx}/bin/osmo-trx-lms -c ${pkgs.writeText "osmo-trx-lms.cfg" cfg.bts.cfgTrx}";
        };
      };

      osmo-bts = mkIf cfg.bts.enable {
        wantedBy = [ "multi-user.target" ];
        requires = [ "network-online.target" ];
        after = [ "network-online.target" "osmo-bsc.service" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-bts}/bin/osmo-bts-${cfg.bts.backend} -c ${pkgs.writeText "osmo-bts.cfg" cfg.bts.cfg}";
        };
      };
    } // listToAttrs (map (name: nameValuePair "osmo-${name}" (service name cfg."${name}".cfg)) services);

    users = mkIf (any (x: cfg."${x}".enable) services) {
      users.osmo = {
        isSystemUser = true;
        group = "osmo";
      };
      groups.osmo = {};
    };
  };
}
