{ config, lib, pkgs, ... } :

with lib;

let
  cfg = config.services.rtpproxy;

in {

  ###### Options
  options = {
    services.rtpproxy = {
      enable = mkEnableOption "rtpproxy";

      listen = mkOption {
        description = "IPv4 listen address (-l option)";
        type = types.str;
        default = "0.0.0.0";
      };

      controlSocket = mkOption {
        description = "Control socket address";
        type = types.str;
        default = "udp:127.0.0.1:7722";
      };

      extraOpts = mkOption {
        description = "Extra command line options";
        type = types.str;
        default = "";
      };
    };
  };

  ###### Implemention
  config = mkIf cfg.enable {
    systemd.services.rtpproxy = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.rtpproxy}/bin/rtpproxy -p /run/rtpproxy/rtpproxy.pid -l ${cfg.listen} -s ${cfg.controlSocket} ${cfg.extraOpts}";
        Restart = "on-failure";
        RestartSec = 10;
        DynamicUser = true;
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        ProtectHome = "yes";
        ProtectSystem = "full";
        PrivateTmp = "yes";
        RuntimeDirectory = "rtpproxy";
        RuntimeDirectoryMode = "0700";
      };
    };
  };
}
