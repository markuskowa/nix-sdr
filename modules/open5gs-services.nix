{ config, pkgs, lib, ... } :

with lib;

let
  cfg = config.services.open5gs;

  formatter = pkgs.formats.yaml {};

  services = [
    "hss"
    "mme"
    "sgwc"
    "sgwu"
    "smf"
    "upf"
    "pcrf"
  ];

  # Service template
  service = name: settings: mkIf cfg."${name}".enable {
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ]
      ++ optional (name == "hss" || name == "pcrf") "mongodb.service" ;

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.open5gs}/bin/open5gs-${name}d -c ${formatter.generate "${name}.yml" settings}";
    };
  };

in {
  config = {
    systemd.services = listToAttrs (map (name: nameValuePair "open5gs-${name}" (service name cfg."${name}".settings)) services);
  };
}
