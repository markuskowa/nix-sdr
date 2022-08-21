{ pkgs, lib, ... } :

let

  common = {
    imports = [ ../modules/lte.nix ];
    nixpkgs.overlays = [ (import ../default.nix) ];
    networking.firewall.enable = false;
  };

in {
  name = "open5gs-nitb";

  nodes = {
    nitb = { config, pkgs, ... } : {
      virtualisation.memorySize = 2048;
      imports = [ common ];

      services.open5gs.nitb.enable = true;

      services.srsran.enodeb.settings.rf = {
        device_name = "zmq";
        device_args = "fail_on_disconnect=true,tx_port=tcp://*:2000,rx_port=tcp://ue:2001,id=enb,base_srate=3.84e6";
      };


      environment.systemPackages = [ (
        pkgs.writeScriptBin "genCerts" ''
          ${pkgs.openssl}/bin/openssl rand -out rnd -hex 256

          mkdir demoCA
          echo 01 > demoCA/serial
          touch demoCA/index.txt.attr
          touch demoCA/index.txt

          out=/var/lib/open5gs
          mkdir -p $out

          # CA self signed certificate
          ${pkgs.openssl}/bin/openssl req -new -batch -x509 -days 3650 -nodes -newkey rsa:1024 -out $out/cacert.pem -keyout $out/cakey.pem -subj /CN=${config.networking.hostName}ca/C=SE/ST=local/L=local/O=Open5GS/OU=Tests

          for i in hss mme smf pcrf; do
            ${pkgs.openssl}/bin/openssl genrsa -out $out/$i.key.pem 1024
            ${pkgs.openssl}/bin/openssl req -new -batch -out $out/$i.csr.pem -key $out/$i.key.pem -subj /CN=$i.lte/C=SE/ST=local/L=local/O=Open5GS/OU=Tests
            ${pkgs.openssl}/bin/openssl ca -cert $out/cacert.pem -days 3650 -keyfile $out/cakey.pem -in $out/$i.csr.pem -out $out/$i.cert.pem -outdir $out -batch
          done
          chown open5gs $out/*
        ''
      ) ];
    };

    ue = {
      imports = [ common ];

      virtualisation.memorySize = 4096;

      services.srsran.ue = {
        enable = true;
        settings.rf = {
          device_name = "zmq";
          device_args = "fail_on_disconnect=true,tx_port=tcp://*:2001,rx_port=tcp://nitb:2000,id=ue,base_srate=3.84e6";
        };
      };
    };
  };

  testScript = ''
    nitb.start();
    nitb.succeed("genCerts");
    nitb.shutdown();

    nitb.wait_for_unit("multi-user.target");

    nitb.wait_for_unit("open5gs-hss");
    nitb.wait_for_unit("open5gs-mme");
    nitb.wait_for_unit("open5gs-smf");
    nitb.wait_for_unit("open5gs-pcrf");
    nitb.wait_for_unit("open5gs-sgwc");
    nitb.wait_for_unit("open5gs-sgwu");

    nitb.succeed("${pkgs.open5gs}/bin/open5gs-dbctl add 001010123456780 00112233445566778899aabbccddeeff 63bfa50ee6523365ff14c1f45f88737d");

    ue.wait_for_unit("srsran-ue");

    ue.wait_until_succeeds("ping -c1 10.45.0.1", timeout=300);
  '';
}
