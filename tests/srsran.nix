{ pkgs, lib, ... } :

let
  user_db = pkgs.writeText "user_db.csv" ''
    ue,mil,001010123456780,00112233445566778899aabbccddeeff,opc,63bfa50ee6523365ff14c1f45f88737d,8000,000000001234,7,dynamic
  '';

  common = {
    imports = [ ../modules/lte.nix ];
    nixpkgs.overlays = [ (import ../default.nix) ];

    networking.firewall.enable = false;
  };

  ipEnodeb = "192.168.2.1";
  ipEpc = "192.168.2.2";
  ipSgi = "192.168.3.1";
in {
  name = "srsran";

  nodes = {
    enodeb = {
      imports = [ common ];

      virtualisation.vlans = [ 1 2 ];
      networking.interfaces.eth2.ipv4.addresses = [ { address = ipEnodeb; prefixLength = 24; } ];

      services.srsran.enodeb = {
        enable = true;
        settings = {
          enb = {
            mme_addr = ipEpc;
            gtp_bind_addr = ipEnodeb;
            s1c_bind_addr = ipEnodeb;
            s1c_bind_port = 0;
            n_prb = 15;
          };

          rf = {
            device_name = "zmq";
            device_args = "fail_on_disconnect=true,tx_port=tcp://*:2000,rx_port=tcp://ue:2001,id=enb,base_srate=3.84e6";
          };
        };
      };
    };

    ue = {
      imports = [ common ];

      virtualisation.memorySize = 4096;
      services.srsran.ue = {
        enable = true;
        settings = {
          rf = {
            device_name = "zmq";
            device_args = "fail_on_disconnect=true,tx_port=tcp://*:2001,rx_port=tcp://enodeb:2000,id=ue,base_srate=3.84e6";
          };
        };
      };
    };

    epc = {
      imports = [ common ];
      virtualisation.vlans = [ 1 2 ];
      networking.interfaces.eth2.ipv4.addresses = [ { address = ipEpc; prefixLength = 24; } ];

      services.srsran.epc = {
        enable = true;
        settings = {
          mme = {
            mme_bind_addr = ipEpc;
            apn = "srsapn";
            dns_addr = "8.8.8.8";
            encryption_algo = "EEA0";
            integrity_algo = "EIA1";
          };

          hss.db_file = toString user_db;

          spgw = {
            gtpu_bind_addr   = ipEpc;
            sgi_if_addr      = ipSgi;
            sgi_if_name      = "srs_spgw_sgi";
          };
        };

      };
    };
  };

  testScript = ''
    epc.wait_for_unit("srsran-epc");
    enodeb.wait_for_unit("srsran-enodeb");
    ue.wait_for_unit("srsran-ue");

    # It takes a bit until the device shows up
    # ue.wait_for_unit("sys-subsystem-net-devices-tun_srsue.device");

    ue.wait_until_succeeds("ping -c1 ${ipSgi}", timeout=300);
  '';
}
