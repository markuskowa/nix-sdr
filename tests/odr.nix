import <nixpkgs/nixos/tests/make-test-python.nix> ({ pkgs, lib, ... } :

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
    encoder.wait_for_unit("multi-user.target")
    encoder.wait_for_unit("odr-audioenc-test.service")
    encoder.wait_for_unit("odr-padenc-test.service")

    mux.wait_for_unit("odr-dabmux.service")

    modulator.wait_for_unit("odr-dabmod.service")
  '';
})
