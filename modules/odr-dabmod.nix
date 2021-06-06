{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.odr.dabmod;

  formatter = pkgs.formats.ini { };

  usergroup = "odrdabmod";

in {
  ###### interface

  options = {
    services.odr.dabmod = {
      enable = mkEnableOption "Opendigital Radio DAB modulator";

      settings =  mkOption {
        default = {};
        type = types.submodule {
          freeformType = formatter.type;
          options = {
            input.transport = mkOption {
              type = types.enum [ "file" "tcp" "zeromq" "edi" ];
              description = "Input transport type.";
              default = "edi";
            };

            modulator = {
              gainmode = mkOption {
                type = types.enum [ "fix" "max" "var" ];
                default = "var";
                description = "Gain mode.";
              };

              rate = mkOption {
                type = types.int;
                default = 2048000;
                description = "Sampling rate.";
              };
            };

            output = {
              output = mkOption {
                type = types.enum [ "uhd" "file" "zmq" "soapysdr" "limesdr" ];
                description = "Output device driver";
                default = "file";
              };
            };
          };
        };
      };
      };
  };

  ###### implementation

  config = {

    # run as user (requires hardware access)
    users.users."${usergroup}" = mkIf cfg.enable {
      description   = "ODR DAB MUX daemon user";
      isSystemUser  = true;
      group         = usergroup;
    };

    users.groups."${usergroup}" = {};

    systemd.services.odr-dabmod = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.odrDabMod}/bin/odr-dabmod ${formatter.generate "mod.cfg" cfg.settings}";
        CPUSchedulingPolicy = "rr";
        CPUSchedulingPriority = 50;
        User = usergroup;
        Group = usergroup;
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
