import <nixpkgs/nixos/tests/make-test-python.nix> ({ pkgs, lib, ... } :

let
  user_db = pkgs.writeText "user_db.csv" ''
    ue,mil,001010123456780,00112233445566778899aabbccddeeff,opc,63bfa50ee6523365ff14c1f45f88737d,8000,000000001234,7,dynamic
  '';

  common = {
    imports = [ ../modules/lte.nix ];
    networking.firewall.enable = false;
  };

  ipSgi = "172.16.0.1";
in {
  name = "srsran-nitb";

  nodes = {
    lteNitb = {
      imports = [ common ];
      virtualisation.memorySize = 2048;

      services.srsran = {
        nitb.enable = true;

        enodeb.settings.rf = {
          device_name = "zmq";
          device_args = "fail_on_disconnect=true,tx_port=tcp://*:2000,rx_port=tcp://ue:2001,id=enb,base_srate=3.84e6";
        };

        epc.settings.hss.db_file = toString user_db;
      };
    };

    ue = {
      imports = [ common ];

      virtualisation.memorySize = 4096;

      services.srsran.ue = {
        enable = true;
        settings.rf = {
          device_name = "zmq";
          device_args = "fail_on_disconnect=true,tx_port=tcp://*:2001,rx_port=tcp://lteNitb:2000,id=ue,base_srate=3.84e6";
        };
      };
    };

  };

  testScript = ''
    lteNitb.wait_for_unit("srsran-epc");
    lteNitb.wait_for_unit("srsran-enodeb");
    ue.wait_for_unit("srsran-ue");

    ue.wait_until_succeeds("ping -c1 ${ipSgi}", timeout=300);
  '';
})
