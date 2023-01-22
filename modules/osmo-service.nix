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
  ];

in {
  options.services.osmo = listToAttrs (map (s: nameValuePair s (options s)) services);

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
          ExecStart = "${pkgs.osmo-bts}/bin/osmo-bts-${cfg.bts.backend} -c ${mlib.osmo-formatter.generate "bts.cfg" cfg.bts.settings}";
          User = "osmo";
          Group = "osmo";
        };
      };

      osmo-sip-connector = mkIf cfg.sip-connector.enable {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-sip-connector}/bin/osmo-sip-connector -c ${mlib.osmo-formatter.generate "sip-connector.cfg" cfg.sip-connector.settings}";
          Restart = "always";
          RestartSec = 2;
          DynamicUser = false;
          RestartPreventExitStatus = 2;
          User = "osmo";
          Group = "osmo";
        };
      };

      osmo-stp = mkIf cfg.stp.enable {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-stp}/bin/osmo-stp -c ${mlib.osmo-formatter.generate "stp.cfg" cfg.stp.settings}";
          Restart = "always";
          RestartSec = 2;
          RestartPreventExitStatus = 2;
          DynamicUser = true;
        };
      };

      osmo-mgw = mkIf cfg.mgw.enable {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-mgw}/bin/osmo-mgw -c ${mlib.osmo-formatter.generate "mgw.cfg" cfg.mgw.settings}";
          Restart = "always";
          RestartSec = 2;
          RestartPreventExitStatus = 2;
          DynamicUser = true;
        };
      };

      osmo-hlr = mkIf cfg.hlr.enable {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-hlr}/bin/osmo-hlr -c ${mlib.osmo-formatter.generate "hlr.cfg" cfg.hlr.settings}";
          Restart = "always";
          RestartSec = 2;
          RestartPreventExitStatus = 2;
          User = "osmo";
          Group = "osmo";
        };
      };

      osmo-msc = mkIf cfg.msc.enable {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-msc}/bin/osmo-msc -c ${mlib.osmo-formatter.generate "msc.cfg" cfg.msc.settings}";
          Restart = "always";
          RestartSec = 2;
          RestartPreventExitStatus = 2;
          User = "osmo";
          Group = "osmo";
        };
      };

      osmo-bsc = mkIf cfg.bsc.enable {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-bsc}/bin/osmo-bsc -c ${mlib.osmo-formatter.generate "bsc.cfg" cfg.bsc.settings}";
          Restart = "always";
          RestartSec = 2;
          RestartPreventExitStatus = 2;
          DynamicUser = true;
          # User = "osmo";
          # Group = "osmo";
        };
      };

      osmo-pcu = mkIf cfg.pcu.enable {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-pcu}/bin/osmo-pcu -c ${mlib.osmo-formatter.generate "pcu.cfg" cfg.pcu.settings}";
          Restart = "always";
          RestartSec = 2;
          RestartPreventExitStatus = 2;
          User = "osmo";
          Group = "osmo";
        };
      };

      osmo-sgsn = mkIf cfg.sgsn.enable {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-sgsn}/bin/osmo-sgsn -c ${mlib.osmo-formatter.generate "sgsn.cfg" cfg.sgsn.settings}";
          Restart = "always";
          RestartSec = 2;
          RestartPreventExitStatus = 2;
          DynamicUser = true;
        };
      };

      osmo-ggsn = mkIf cfg.ggsn.enable {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.osmo-ggsn}/bin/osmo-ggsn -c ${mlib.osmo-formatter.generate "ggsn.cfg" cfg.ggsn.settings}";
          Restart = "always";
          RestartSec = 2;
          RestartPreventExitStatus = 2;
          User = "osmo";
          Group = "osmo";
        };
      };
    } // listToAttrs (map (name: nameValuePair "osmo-${name}" (service name cfg."${name}".cfg)) services);

    users = mkIf (any (x: cfg."${x}".enable) [ "bsc" "msc" "hlr" "stp" "mgw" "sip-connector" "bts" "pcu" "sgsn" "ggsn"]) {
      users.osmo = {
        isSystemUser = true;
        group = "osmo";
      };
      groups.osmo = {};
    };
  };
}
