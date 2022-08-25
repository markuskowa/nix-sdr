pkgs: lib:

with lib;

{
  # Create a diameter config file from module options
  makeDiameterConf = name: extPath: cfg: pkgs.writeText "${name}.conf" ''
    Identity = "${cfg.identity}";
    Realm = "${cfg.realm}";
    ${concatStringsSep "\n" (map (x:
        ''ListenOn = "${x}";''
      ) cfg.listenOn) }
    ${optionalString (!cfg.ipv4) "No_IP;" }
    ${optionalString (!cfg.ipv6) "No_IPv6;" }
    Port = ${toString cfg.port};
    SecPort = ${toString cfg.secPort};
    ${optionalString (!cfg.relay) "NoRelay;"}
    TLS_Cred = "${cfg.tls.cert}", "${cfg.tls.key}";
    TLS_CA = "${cfg.tls.ca}";

    ${concatStringsSep "\n" (map (x: (
          ''LoadExtension = "${extPath}/${x.module}"''
        + optionalString (x.option != null) '' : "${x.option}"''
        + '';''
      )) cfg.extensions)}

    ${concatStringsSep "\n" (map (x:
          ''ConnectPeer = "${x.peer}" {''
        +     optionalString (x.addr != null) '' ConnectTo = "${x.addr}"; ''
        + ''${optionalString (!x.tls) "No_TLS; "}''
        + ''${x.options}''
        + ''};''
      ) cfg.peers)}
  '';

  # Open5GS can take a simplified subset directly in YAML
  makeDiameterYaml = name: peer: listen: peerIp: {
    identity = "${name}.lte";
    realm = "lte";
    listen_on = "${listen}";
    no_fwd = true;

    load_extension = [
      { module = "${pkgs.open5gs}/lib/freeDiameter/dbg_msg_dumps.fdx"; conf = "0x8888"; }
      { module = "${pkgs.open5gs}/lib/freeDiameter/dict_rfc5777.fdx"; }
      { module = "${pkgs.open5gs}/lib/freeDiameter/dict_mip6i.fdx"; }
      { module = "${pkgs.open5gs}/lib/freeDiameter/dict_nasreq.fdx"; }
      { module = "${pkgs.open5gs}/lib/freeDiameter/dict_nas_mipv6.fdx"; }
      { module = "${pkgs.open5gs}/lib/freeDiameter/dict_dcca.fdx"; }
      { module = "${pkgs.open5gs}/lib/freeDiameter/dict_dcca_3gpp.fdx"; }
    ];
    connect = [
      { identity = "${peer}.lte"; addr = "${peerIp}"; }
    ];
  };

  # Template for a freeDiameter config module
  freediameterModule = {
    identity = mkOption { type = types.str; };
    realm = mkOption { type = types.str; };
    listenOn = mkOption { type = with types; listOf str; };
    port = mkOption { type = types.port;  default = 3868; };
    secPort = mkOption { type = types.port;  default = 5868; };
    ipv4 = mkOption { type = types.bool;  default = true; };
    ipv6 = mkOption { type = types.bool;  default = false; };
    relay = mkOption { type = types.bool;  default = true; };

    tls = {
      cert = mkOption { type = types.str; };
      key = mkOption { type = types.str; };
      ca = mkOption { type = types.str; };
    };

    extensions = mkOption {
      type = with types; listOf ( submodule ({...} : {
        options = {
          module = mkOption { type = types.str; };
          option = mkOption { type = types.nullOr types.str; default = null; };
        };
      }));
      default = [];
    };

    peers = mkOption {
      type = with types; listOf ( submodule ({...} : {
        options = {
          peer = mkOption { type = types.str; };
          addr = mkOption { type = nullOr str; default = null; };
          tls = mkOption {
            type = types.bool;
            default = true;
          };
          options = mkOption { type = types.str; default = ""; };
        };
      }));
    };
  };
}
