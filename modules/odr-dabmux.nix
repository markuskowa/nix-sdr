{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.odr.dabmux;

  configMux = pkgs.writeText "config.mux" ''
    general {
      dabmode ${toString cfg.dabmode}
      nbframes ${toString cfg.nbframes}
      ${cfg.extraConfigGeneral}
    }

    ensemble {
      ecc ${cfg.ecc}
      id ${cfg.id}
      label "${cfg.label}"
      ${cfg.extraConfigEnsemble}
    }

    outputs {
      ${concatStringsSep "\n" cfg.outputs}
    }

    services {
       ${concatStringsSep "\n" (attrValues (mapAttrs (name: c: ''
         service-${name} {
           id ${c.serviceId}
           label "${c.label}"
           ${c.extraConfigService}
         }
       '') cfg.streams))}
    }

    subchannels {
       ${concatStringsSep "\n" (attrValues (mapAttrs (name: c: ''
         subchannel-${name} {
           type "${c.channelType}"
           inputfile "${c.inputfile}"
           bitrate ${toString c.bitrate}
           protection ${toString c.protection}
           zmq-buffer ${toString c.zmq-buffer}
           zmq-prebuffering ${toString c.zmq-prebuffering}
           ${c.extraConfigSubchannel}
         }
       '') cfg.streams))}
    }

    components {
       ${concatStringsSep "\n" (attrValues (mapAttrs (name: c: ''
         component-${name} {
           type 0
           service service-${name}
           subchannel subchannel-${name}
           ${optionalString c.slideShow "figtype 0x2"}
           ${c.extraConfigComponent}
         }
       '') cfg.streams))}
    }

    ${cfg.extraConfig}
  '';

in
{
  ###### interface

  options = {
    services.odr.dabmux = {
        enable = mkEnableOption "Opendigital Radio DAB multiplexer";

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

        extraConfigGeneral = mkOption {
          type = types.str;
          default = "";
          description = "Extra config for the 'general' section";
        };

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

        extraConfigEnsemble = mkOption {
          type = types.str;
          default = "";
          description = "Extra config for the 'ensemble' section";
        };

        outputs = mkOption {
          type = types.listOf types.str;
          default = [ "throttle \"simul://\"" "tcp \"tcp://*:9030\"" ];
          description = "Output definitions.";
        };

        extraConfig = mkOption {
          type = types.str;
          default = "";
          description = "Extra contents of config file.";
        };

        streams = mkOption {
          default = {};
          description = ''
            Simplified setup for Services/subchannels/components.
            Every entry creates one service, one sub channel, and component
          '';

        type = types.attrsOf (types.submodule ({ config, ... }: {
          options = {
            serviceId = mkOption {
              type = types.strMatching "0x[0-9a-fA-F]{4}";
              description = "Service ID";
            };

            label = mkOption {
              type = types.str;
              description = "Label of the service.";
            };

            inputfile = mkOption {
              type = types.str;
              description = "Input file name for URL.";
            };

            slideShow = mkOption {
              type = types.bool;
              default = false;
              description = "Set figtype to 0x2 (MOT Slideshow)";
            };

            bitrate = mkOption {
              type = types.ints.between 16 192;
              default = 96;
              description = "Audio bitrate of the channel.";
            };

            zmq-buffer = mkOption {
              type = types.int;
              default = 10;
              description = "Maximum buffer size in frames (24 ms per frame).";
            };

            zmq-prebuffering = mkOption {
              type = types.int;
              default = 5;
              description = "Number of frames in buffer before streaming starts.";
            };

            protection = mkOption {
              type = types.ints.between 1 4;
              default = 3;
              description = "EEP protection class.";
            };

            channelType = mkOption {
              type = types.enum [ "audio" "dabplus" ];
              default = "dabplus";
              description = "Content type of the channel.";
            };

            extraConfigService = mkOption {
              type = types.str;
              default = "";
              description = "Extra contents of service definition.";
            };

            extraConfigSubchannel = mkOption {
              type = types.str;
              default = "";
              description = "Extra contents of sub channel definition.";
            };

            extraConfigComponent = mkOption {
              type = types.str;
              default = "";
              description = "Extra contents of component definition.";
            };
          };
        }));
      };
    };
  };

  ###### implementation

  config = {
    systemd.services.odr-dabmux = mkIf (config.services.odr.enable && cfg.enable) {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.odrDabMux}/bin/odr-dabmux ${configMux}";
        CPUSchedulingPolicy = "rr";
        CPUSchedulingPriority = 50;
        User = "odruser";
        Group = "odrgroup";
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}

