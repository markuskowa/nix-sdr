{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.odr.audioenc;

  usergroup = "odrenc";

  ###### Service modules

  #
  # encoder service
  #
  audioEncService = name: cfg:
  let
    socketid = "odr-${name}.pad";
  in {
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
          -r ${toString cfg.rate} \
          -c ${toString cfg.channels} \
          ${optionalString cfg.pad.enable (
            "-P ${socketid} -p ${toString cfg.padBytes}"
          )} \
          --identifier=${if cfg.identifier == null then name else cfg.identifier} \
          ${if cfg.outputType == "edi" then "-e" else "-o"} ${cfg.output} \
          -g '${toString cfg.gain}' \
          ${cfg.cmdlineOptions}
      '';
      PermissionsStartOnly = "true";
      RuntimeDirectory = "odr-audio-${name}";
      User = usergroup;
      Group = usergroup;
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
      User = usergroup;
      Group = usergroup;
    };
  };

in {
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
              type = types.ints.between 16 192;
              default = 96;
              description = "Channel bit rate in kbit/s." ;
            };

            channels = mkOption {
              type = types.enum [ 1 2 ];
              default = 2;
              description = "Number of audio channels." ;
            };

            rate = mkOption {
              type = types.enum [ 32000 48000 ];
              default = 48000;
              description = "Sample rate." ;
            };

            identifier = mkOption {
              type = with types; nullOr str;
              default = null;
              description = "EDI identifier tag." ;
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

            outputType = mkOption {
              type = types.enum [ "eti" "edi" ];
              default = "edi";
              description = "ETI output to file, zmq, stdout (-o) or EDI (-e)";
            };

            output = mkOption {
              type = types.str;
              default = null;
              description = "Output URI.";
              example = "tcp://localhost:9001";
            };

            gain = mkOption {
              type = types.int;
              default = 0;
              description = "Gain in dB,";
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
                description = "Command line options for odr-padenc.";
              };
            };

          };
        }));
    };
  };

  ###### implementation

  config = let
    enabled = foldr (l: r: l || r) false (
      mapAttrsToList (n: v: v.enable) cfg
    );

  in mkIf enabled {

    # Create audio encoder services
    systemd.services = (mapAttrs' ( name: c:
      nameValuePair "odr-audioenc-${name}" (
        mkIf c.enable (audioEncService name c)
      )
    ) cfg) // mapAttrs' ( name: c:
      nameValuePair "odr-padenc-${name}" (
        mkIf c.pad.enable (padEncService name c)
      )
      ) cfg;

    # user/group for all encoders
    users.users.${usergroup} = {
      description = "ODR audio/pad encoder daemon user";
      isSystemUser = true;
      group = usergroup;
    };

    users.groups.${usergroup} = {};
  };
}

