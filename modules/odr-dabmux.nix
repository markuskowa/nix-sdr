{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.odr.dabmux;

  usergroup = "odrdabmux";

  # formatter
  attrsToString = set: concatStringsSep "\n" (
    mapAttrsToList (key: val: valueToString key val) set );

  valueToString = key: val:
    if isList val then concatStringsSep "," (map (x: valueToString x) val)
    else if isAttrs val then "${key} {\n${attrsToString val}\n}"
    else if isBool val then "${key} ${if val then "true" else "false"}"
    else "${key} ${toString val}";

  formatter = {
    type = with types; let
      valueType = oneOf [
        bool
        int
        float
        str
        (listOf valueType)
        (attrsOf valueType)
      ] // {
        description = "odrDabMux config file format";
      };
    in valueType;

    generate = name: value:
      pkgs.writeText name (attrsToString value);
   };

in {
  ###### interface

  options = {
    services.odr.dabmux = {
      enable = mkEnableOption "Opendigital Radio DAB multiplexer";

      settings = {
        # Required sections
        general = mkOption {
          default = {};
          type = types.submodule {
            freeformType = formatter.type;
            options = {
              dabmode = mkOption {
                type = types.ints.between 1 4;
                default = 1;
                description = "DAB transmission mode (2-4 are outdated).";
              };

              nbframes = mkOption {
                type = types.int;
                default = 0;
                description = "Number of frames to generate.";
              };
            };
          };
        };

        remotecontrol = mkOption {
          default = {};
          type = types.submodule {
            freeformType = formatter.type;
          };
        };

        ensemble = mkOption {
          default = {};
          type = types.submodule {
            freeformType = formatter.type;
            options = {
              ecc = mkOption {
                type = types.strMatching "0x[0-9a-fA-F]{2}";
                default = "0x00";
                description = "Extended Country Code";
              };

              id = mkOption {
                type = types.strMatching "0x[0-9a-fA-F]{4}";
                default = "0x0000";
                description = "Ensemble ID";
              };

              label = mkOption {
                type = types.str;
                default = "NixOS ODR";
                description = "Name of the ensemble.";
              };
            };
          };
        };

        outputs = mkOption {
          type = types.submodule {
            freeformType = formatter.type;
          };
        };

        services = mkOption {
          type = types.attrsOf (types.submodule {
            freeformType = formatter.type;
            options = {
              id = mkOption {
                type = types.strMatching "0x[0-9a-fA-F]{4}";
                default = null;
                description = "Service ID";
              };

              label = mkOption {
                type = types.str;
                default = null;
                description = "Service label";
              };

            };
          });
        };

        subchannels = mkOption {
          type = types.attrsOf (types.submodule {
            freeformType = formatter.type;
            options = {
              type = mkOption {
                default = "dabplus";
                type = types.enum [
                  "audio"
                  "dabplus"
                  "data"
                  "packet"
                  "enhancedpacket"
                ];
              };

              bitrate = mkOption {
                type = types.ints.between 16 192;
                default = 96;
                description = "Bitrate of the channel.";
              };

              protection = mkOption {
                type = types.ints.between 1 4;
                default = 3;
                description = "EEP protection class.";
              };

              id = mkOption {
                type = types.ints.u8;
                description = "Subchannel id.";
                default = null;
              };
            };
          });
        };

        components = mkOption {
          type = types.attrsOf (types.submodule {
            freeformType = formatter.type;
          });
        };

        linking = mkOption {
          default = {};
          type = types.attrsOf (types.submodule {
            freeformType = formatter.type;
          });
        };

        frequency_information = mkOption {
          default = {};
          type = types.attrsOf (types.submodule {
            freeformType = formatter.type;
          });
        };

        other-services = mkOption {
          default = {};
          type = types.attrsOf (types.submodule {
            freeformType = formatter.type;
          });
        };
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.services.odr-dabmux = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.odrDabMux}/bin/odr-dabmux ${formatter.generate "mux.cfg" cfg.settings}";
        CPUSchedulingPolicy = "rr";
        CPUSchedulingPriority = 50;
        DynamicUser = true;
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}

