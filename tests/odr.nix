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
        settings = {
          outputs = {
            throttle = "simul://";
            edi.destinations.tcp = {
              protocol = "tcp";
              listenport = 9030;
            };
          };

          services.test = {
            id = "0x0001";
            label = "Test";
          };

          subchannels.test = {
            type = "dabplus";
            id = 1;
            bitrate = 128;
            inputuri = "tcp://*:9000";
            inputproto = "edi";
          };

          components.test = {
            service = "test";
            subchannel = "test";
          };
        };
      };
    };

    modulator = { ... } : {
      imports = [ defconf ];
      services.odr.dabmod = {
        enable = true;
        settings = {
          input = {
            transport = "edi";
            source = "tcp://mux:9030";
          };
          output.output = "file";
          fileoutput.filename = "/dev/null";
        };
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
