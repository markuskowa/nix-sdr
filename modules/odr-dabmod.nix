{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.odr.dabmod;

  configMod = pkgs.writeText "config.mod" ''
    [input]
    transport=${cfg.transport}
    source=${cfg.source}
    ${cfg.extraConfigInput}

    [modulator]
    gainmode=${cfg.gainmode}
    rate=${toString cfg.rate}
    ${cfg.extraConfigModulator}

    [output]
    output=${cfg.output}

    ${if cfg.output == "file" then "[fileoutput]" else
      if cfg.output == "uhd"  then "[uhdoutput]"  else
      if cfg.output == "zmq"  then "[zmqoutput]"  else
      "[soapyoutput]"}

    ${optionalString (cfg.channel != null) cfg.channel}
    ${optionalString (cfg.txgain != null) (toString cfg.txgain)}

    ${cfg.extraConfig}
  '';

in
{
  ###### interface

  options = {
    services.odr.dabmod = {
        enable = mkEnableOption "Opendigital Radio DAB modulator";

        transport = mkOption {
          type = types.enum [ "file" "tcp" "zeromq" "edi" ];
          description = "Input transport type.";
        };

        source = mkOption {
          type = types.str;
          description = "Source path/URL for input.";
        };

        extraConfigInput = mkOption {
          type = types.str;
          default = "";
          description = "Extra options for the input section.";
        };

        gainmode = mkOption {
          type = types.enum [ "fix" "max" "var" ];
          default = "var";
          description = "Modulator gain mode.";
        };

        rate = mkOption {
          type = types.int;
          default = 2048000;
          description = "Modulator sampling rate.";
        };

        extraConfigModulator = mkOption {
          type = types.str;
          default = "";
          description = "Extra options for modulator section.";
        };

        output = mkOption {
          type = types.enum [ "uhd" "file" "zmq" "soapysdr" ];
          description = "Output device driver";
        };

        channel = mkOption {
          type = types.nullOr types.string;
          default = null;
          description = "Do not set if you want to use the frequency option or choose file/zmq output.";
        };

        txgain = mkOption {
          type = types.nullOr types.float;
          default = null;
          description = "HW TX gain for output device";
        };

        extraConfig = mkOption {
          type = types.str;
          default = null;
          description = "Extra configuration. Starts in the [*output] section.";
        };
      };
  };

  ###### implementation

  config = {
    systemd.services.odr-dabmod = mkIf (config.services.odr.enable && cfg.enable) {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.odrDabMod}/bin/odr-dabmod ${configMod}";
        CPUSchedulingPolicy = "rr";
        CPUSchedulingPriority = 50;
        User = "odruser";
        Group = "odrgroup";
      };
    };
  };
}

