{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.osmo;

  mlib = import ./lib.nix pkgs lib;

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
        type = with types; nullOr str;
        default = null;
      };
    };
  } // listToAttrs (map (s: nameValuePair s (options s)) services);

  config = {
    systemd.services = {
      osmo-trx = mkIf (cfg.bts.enable && cfg.bts.backend == "trx" && cfg.bts.cfgTrx != null) {
        wantedBy = [ "multi-user.target" ];
        requires = [ "network-online.target" ];
        after = [ "network-online.target" "osmo-bts.service" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-trx}/bin/osmo-trx-lms -C ${pkgs.writeText "osmo-trx-lms.cfg" cfg.bts.cfgTrx}";
        };
      };

      osmo-bts = mkIf cfg.bts.enable {
        wantedBy = optional (cfg.bts.backend == "trx") "osmo-trx.service";
        requires = [ "network-online.target" ];
        bindsTo = optional (cfg.bts.backend == "trx") "osmo-trx.service";
        after = [ "network-online.target" "osmo-bsc.service" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-bts}/bin/osmo-bts-${cfg.bts.backend} -c ${pkgs.writeText "osmo-bts.cfg" cfg.bts.cfg}";
          User = "osmo";
          Group = "osmo";
        };
      };

      osmo-sip-connector = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-sip-connector}/bin/osmo-sip-connector -c ${mlib.osmo-formatter.generate "sip-connector.cfg" cfg.sip-connector.settings}";
          Restart = "always";
          RestartSec = 2;
          DynamicUser = false;
          User = "osmo";
          Group = "osmo";
        };
      };

      osmo-stp = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-stp}/bin/osmo-stp -c ${mlib.osmo-formatter.generate "stp.cfg" cfg.stp.settings}";
          Restart = "always";
          RestartSec = 2;
          DynamicUser = true;
        };
      };

      osmo-mgw = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-mgw}/bin/osmo-mgw -c ${mlib.osmo-formatter.generate "mgw.cfg" cfg.mgw.settings}";
          Restart = "always";
          RestartSec = 2;
          DynamicUser = true;
        };
      };

      osmo-hlr = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-hlr}/bin/osmo-hlr -c ${mlib.osmo-formatter.generate "hlr.cfg" cfg.hlr.settings}";
          Restart = "always";
          RestartSec = 2;
          User = "osmo";
          Group = "osmo";
        };
      };

      osmo-msc = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-msc}/bin/osmo-msc -c ${mlib.osmo-formatter.generate "msc.cfg" cfg.msc.settings}";
          Restart = "always";
          RestartSec = 2;
          User = "osmo";
          Group = "osmo";
        };
      };

      osmo-bsc = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-bsc}/bin/osmo-bsc -c ${mlib.osmo-formatter.generate "bsc.cfg" cfg.bsc.settings}";
          Restart = "always";
          RestartSec = 2;
          User = "osmo";
          Group = "osmo";
        };
      };
    } // listToAttrs (map (name: nameValuePair "osmo-${name}" (service name cfg."${name}".cfg)) services);

    users = mkIf (any (x: cfg."${x}".enable) [ "bsc" "msc" "hlr" "stp" "mgw" "sip-connector" ]) {
      users.osmo = {
        isSystemUser = true;
        group = "osmo";
      };
      groups.osmo = {};
    };
  };
}
