import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, lib, ... } :

let
  defconf = {
    imports = [ ../modules/odr.nix ];

    nixpkgs.overlays = [ (import ../default.nix) ];
    services.odr.enable = true;
    networking.firewall.enable = false;
  };

  stationDLS = pkgs.writeText "station.dls" ''
    ##### parameters { #####
    DL_PLUS=1
    DL_PLUS_TAG=31 0 4
    ##### parameters } #####
    TEST
  '';

in {
  name = "odr";
  meta = with lib.maintainers; {
    maintainers = [ markuskowa ];
  };

  nodes = {
    encoder = { ... } : {
      imports = [ defconf ];
      services.odr.audioenc.test = {
        enable = true;
        input = "-i /dev/zero";
        output = "tcp://mux:9000";
        pad = {
          enable = true;
          dlsFiles = [ "${stationDLS}" ];
        };
      };
    };

    mux = { ... } : {
      imports = [ defconf ];
      services.odr.dabmux = {
        enable = true;
        streams.tests = {
          serviceId = "0x0001";
          label = "TEST";
          inputfile = "tcp://*:9000";
        };
        outputs = [ "throttle \"simul://\"" ''
            edi {
              destinations {
                example_tcp {
                  protocol tcp
                  listenport 9030
                }
              }
            }
          ''
        ];
      };
    };

    modulator = { ... } : {
      imports = [ defconf ];
      services.odr.dabmod = {
        enable = true;
        transport="edi";
        source="tcp://mux:9030";

        output="file";
        extraConfig = "filename=/dev/null";
      };
    };
  };

  testScript = ''
    $encoder->waitForUnit("multi-user.target");
    $encoder->waitForUnit("odr-audioenc-test.service");
    $encoder->waitForUnit("odr-padenc-test.service");

    $mux->waitForUnit("odr-dabmux.service");

    $modulator->waitForUnit("odr-dabmod.service");
  '';
})
