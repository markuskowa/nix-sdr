{ pkgs, lib, ... } :

let

  common = {
    imports = [ ../modules/osmo-gsm.nix ];
    nixpkgs.overlays = [ (import ../default.nix) ];

    networking.firewall.enable = false;
  };

in {
  name = "osmocom";

  nodes = {
    nitb = {config, ... } : {
      imports = [ common ];


      services.osmo.nitb = {
        enable = true;
      };

      services.osmo.bts = {
        enable = true;
        cfg = ''
          e1_input
           e1_line 0 driver ipa
           e1_line 0 port 0
           no e1_line 0 keepalive
          phy 0
           instance 0
          bts 0
           band ${config.services.osmo.nitb.band}
           ipa unit-id 10 0
           oml remote-ip 127.0.0.1
           rtp jitter-buffer 100
           paging queue-size 200
           paging lifetime 0
           min-qual-rach 50
           min-qual-norm -5
           trx 0
            power-ramp max-initial 23000 mdBm
            power-ramp step-size 2000 mdB
            power-ramp step-interval 1
            ms-power-control osmo
            phy 0 instance 0
        '';
      };
    };

  };

  testScript = ''
    nitb.succeed("mkdir -p /var/lib/osmo-hlr; ${pkgs.osmo-hlr}/bin/osmo-hlr-db-tool -l /var/lib/osmo-hlr/hlr.db create");
    nitb.succeed("systemctl restart osmo-hlr");
    nitb.wait_for_unit("osmo-hlr.service")
    nitb.wait_for_unit("osmo-msc.service")
    nitb.wait_for_unit("osmo-mgw.service")
    nitb.wait_for_unit("osmo-stp.service")
    nitb.wait_for_unit("osmo-bsc.service")
    nitb.wait_for_unit("osmo-bts.service")
  '';
}
