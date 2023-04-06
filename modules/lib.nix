#
# Various module related functions
#

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

  #
  # Template for a freeDiameter config module
  #
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
            default = false;
          };
          options = mkOption { type = types.str; default = ""; };
        };
      }));
    };
  };

  # Formatter for Osmocon config files
  osmo-formatter = let
    defaultPrio = 255;
    settingsToCfg = settings:
      concatStringsSep "\n" (flatten (cleanListAttrs (handleAttrs (prioSet settings) "")));

    # Clean up list/attr structure
    cleanListAttrs = map (x:
        if isAttrs x
        then if isList x._v
          then cleanListAttrs x._v
          else x._v
        else if isList x
          then cleanListAttrs x
          else x);

    # transfrom into uniform ordered set
    prioSet = mapAttrs (name: value:
           if isAttrs value then
             if value ? _p && value ? _v then
               if isAttrs value._v
               then { inherit (value) _p; _v = prioSet value._v; }
               else value
             else { _p = defaultPrio; _v = prioSet value; }
           else { _p = defaultPrio; _v = value; });

    # transform values
    handleAttrs = pAttrs: indent:
      sort (x: y: x._p < y._p) (mapAttrsToList (name: value:
        if isAttrs value._v
        then { inherit (value) _p; _v = ["${indent}${name}" (handleAttrs value._v (indent + " "))]; }
        else
          if isList value._v
          then { inherit (value) _p; _v = concatStringsSep " " (map (x: indent + "${toString x}") value._v); }
          else { inherit (value) _p; _v = indent + "${name} ${toString value._v}"; }
    ) pAttrs);

  in {
    type = with types; let
      valueType = oneOf [
        str int
        (attrsOf valueType)
        (listOf valueType)
      ] // {
        description = "Osmocom configuration files";
      };
    in valueType;

    mkPrio = p: v: { _p = p; _v = v; };
    generate = name: settings:
      pkgs.writeText name (settingsToCfg settings);
  };
}
