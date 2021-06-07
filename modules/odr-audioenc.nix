{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.odr.audioenc;

  ###### Service modules

  #
  # encoder service
  #
  audioEncService = name: cfg:
  let
    socketid = "odr-${name}.pad";
  in {
    enable = true;
    path = with pkgs; [ coreutils ];

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "network.target" ];


    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.odrAudioEnc}/bin/odr-audioenc \
          ${cfg.input} \
          -b ${toString cfg.bitrate} \
          ${optionalString cfg.pad.enable ("-P ${socketid} -p ${toString cfg.padBytes}")} \
          ${cfg.cmdlineOptions}
      '';
      PermissionsStartOnly = "true";
      RuntimeDirectory = "odr-audio-${name}";
      User = "odruser";
      Group = "odrgroup";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  #
  # PAD service
  #
  padEncService = name: cfg:
  let
    socketid = "odr-${name}.pad";
  in {
    path = with pkgs; [ coreutils ];

    wantedBy = [ "multi-user.target" ];
    after = [ "odr-audioenc-${name}.service" ];
    bindsTo = [ "odr-audioenc-${name}.service" ];
    partOf = [ "odr-audioenc-${name}.service" ];

    serviceConfig = {
      Type = "simple";

      ExecStart = ''
        ${pkgs.odrPadEnc}/bin/odr-padenc \
        -o ${socketid} ${optionalString (cfg.pad.motDir != null) "-d ${cfg.pad.motDir}"} \
        ${concatMapStrings (dir: "-t ${dir} ") cfg.pad.dlsFiles} \
        ${cfg.pad.cmdlineOptions}
      '';
      RuntimeDirectory = "odr-pad-${name}";
      User = "odruser";
      Group = "odrgroup";
    };
  };

in
{
  ###### interface

  options = {
    services.odr.audioenc = mkOption {
        default = {};
        description = ''
          Opendigital radio DAB audio encoders
        '';

        type = types.attrsOf (types.submodule ({ config, ... }: {
          options = {
            enable = mkEnableOption "audio encoder";

            bitrate = mkOption {
              type = types.int;
              default = 96;
              description = "Audio bit rate in kbit/s." ;
            };

            padBytes = mkOption {
              type = types.int;
              default = 58;
              description = "Length of PAD in bytes.";
            };

            input = mkOption {
              type = types.str;
              default = null;
              description = "Input specification.";
            };

            output = mkOption {
              type = types.str;
              default = null;
              description = "Output specification.";
            };

            cmdlineOptions = mkOption {
              default = "";
              type = types.str;
              description = "Command line options for odr-audioenc.";
            };

            pad = {
              enable = mkEnableOption "PAD encoder for audio encoder";

              motDir = mkOption {
                default = null;
                type = types.nullOr types.str;
                description = "Path to the slide show image folder .";
              };

              dlsFiles = mkOption {
                type = types.listOf types.string;
                default = [ ];
                description = "List of DLS files to read DLS text from.";
              };

              cmdlineOptions = mkOption {
                default = "";
                type = types.str;
                description = "Command line options for odr-audioenc.";
              };
            };

          };
        }));
    };
  };

  ###### implementation

  config = {

    # Create audio encoder services
    systemd.services = (mapAttrs' ( name: cfg:
      nameValuePair "odr-audioenc-${name}" (
        mkIf cfg.enable (audioEncService name cfg)
      )
    ) cfg) // mapAttrs' ( name: cfg:
      nameValuePair "odr-padenc-${name}" (
        mkIf cfg.pad.enable (padEncService name cfg)
      )
    ) cfg;
  };
}

