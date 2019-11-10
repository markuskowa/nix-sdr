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
    fifoPath = "/run/odr-${name}/pad.fifo";
  in {
    enable = true;
    path = with pkgs; [ coreutils ];

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "network.target" ];

    preStart = optionalString cfg.pad.enable ''
      mkdir -p /run/odr-${name}
      if [ ! -p ${fifoPath} ]; then
        mkfifo ${fifoPath}
        chown -R odruser:odrgroup /run/odr-${name}
        chmod 0770 /run/odr-${name}
      fi
    '';

    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.odrAudioEnc}/bin/odr-audioenc \
          -i ${cfg.input} \
          -b ${toString cfg.bitrate} \
          ${optionalString cfg.pad.enable ("-P ${fifoPath} -p ${toString cfg.padBytes}")} \
          -o ${cfg.output} \
          ${cfg.cmdlineOptions}
      '';
      PermissionsStartOnly = "true";
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
    fifoPath = "/run/odr-${name}/pad.fifo";
  in {
    path = with pkgs; [ coreutils ];

    wantedBy = [ "multi-user.target" ];
    after = [ "odr-audioenc-${name}.service" ];
    bindsTo = [ "odr-audioenc-${name}.service" ];
    partOf = [ "odr-audioenc-${name}.service" ];

    preStart = ''
      if [ ! -p ${fifoPath} ]; then
        sleep 5
      fi
    '';

    serviceConfig = {
      Type = "simple";

      ExecStart = ''
        ${pkgs.odrPadEnc}/bin/odr-padenc \
        -o ${fifoPath} ${optionalString (cfg.pad.motDir != null) "-d ${cfg.pad.motDir}"} \
        -p ${toString cfg.padBytes} \
        ${concatMapStrings (dir: "-t ${dir} ") cfg.pad.dlsFiles} \
        ${cfg.pad.cmdlineOptions}
      '';
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

  config = mkIf config.services.odr.enable {

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

