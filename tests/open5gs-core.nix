{ pkgs, lib, ... } :

with lib;
let

  common = {
    imports = [
      ../modules/lte.nix
      ../modules/freediameter.nix
    ];
    nixpkgs.overlays = [ (import ../default.nix) ];
    networking.firewall.enable = false;

    # Make sure hosts resolve for TLS
    networking.extraHosts = with addrs; ''
      ${mmeDia} mme.lte
      ${hssDia} hss.lte
      ${draDia} dra.lte
      ${smfDia} smf.lte
      ${pcrfDia} pcrf.lte
    '';
  };

  addrs = {
    dra = "10.20.3.1";

    enodebAir = "10.20.5.1";
    enodebS1 = "10.20.1.1";
    enodebUser = "10.20.4.1";

    ueAir = "10.20.5.2";

    mmeS1 = "10.20.1.2";
    mmeCtrl = "10.20.2.2";

    smfCtrl = "10.20.2.5";
    smfUser = "10.20.4.5";

    upfCtrl = "10.20.2.6";
    upfUser = "10.20.4.6";

    sgwcCtrl = "10.20.2.7";

    sgwuCtrl = "10.20.2.8";
    sgwuS1 = "10.20.1.8";
    sgwuUser = "10.20.4.8";

    draDia = "10.20.3.1";
    mmeDia = "10.20.3.2";
    hssDia = "10.20.3.3";
    pcrfDia = "10.20.3.4";
    smfDia = "10.20.3.5";

    apn = "10.20.10.254";
  };

  subnets = {
    s1 = "10.20.1.0";
    crtl = "10.20.2.0";
    dia = "10.20.3.0";
    user = "10.20.4.0";
    air = "10.20.5.0";
    apn = "10.20.10.0";
  };

  makeDiameter = name: peer: listen: mkForce {
    identity = "${name}.lte";
    realm = "lte";
    listenOn = [ listen ];
    relay = false;

    tls = {
      cert = "/run/${name}.cert.pem";
      key  = "/run/${name}.key.pem";
      ca = "/run/cacert.pem";
    };

    extensions = [
      { module = "dbg_msg_dumps.fdx"; option = "0x8888"; }
      { module = "dict_rfc5777.fdx"; }
      { module = "dict_mip6i.fdx"; }
      { module = "dict_nasreq.fdx"; }
      { module = "dict_nas_mipv6.fdx"; }
      { module = "dict_dcca.fdx"; }
      { module = "dict_dcca_3gpp.fdx"; }
    ];

    peers = [
      { peer = "${peer}.lte"; }
    ];
  };

in {
  name = "open5gs-core";

  # networks:
  # 1. enodeb S1
  # 2. Control plane
  # 3. Diameter
  # 4. User plane
  # 5. Air interface

  nodes = {
    enodeb = {config, ...} : {
      imports = [ common ];
      virtualisation.vlans = [ 1 4 5 ];
      virtualisation.memorySize = 2048;

      networking.interfaces = {
        eth1.ipv4.addresses = [{ address = addrs.enodebS1; prefixLength = 24; }];
        eth2.ipv4.addresses = [{ address = addrs.enodebUser; prefixLength = 24; }];
        eth3.ipv4.addresses = [{ address = addrs.enodebAir; prefixLength = 24; }];
      };

      services.srsran.enodeb = {
        enable = true;
        settings = {
          enb = {
            mme_addr      = addrs.mmeS1;
            gtp_bind_addr = addrs.enodebS1;
            s1c_bind_addr = addrs.enodebS1;
            mcc           = config.services.open5gs.net.mcc;
            mnc           = config.services.open5gs.net.mnc;
          };
          rf = {
            device_name = "zmq";
            device_args = "fail_on_disconnect=true,tx_port=tcp://*:2000,rx_port=tcp://${addrs.ueAir}:2001,id=enb,base_srate=3.84e6";
          };
        };
      };
    };

    ue = {
      imports = [ common ];
      virtualisation.vlans = [ 5 ];
      networking.interfaces = {
        eth1.ipv4.addresses = [{ address = addrs.ueAir; prefixLength = 24; }];
      };
      virtualisation.memorySize = 4096;

      services.srsran.ue = {
        enable = true;
        settings.rf = {
          device_name = "zmq";
          device_args = "fail_on_disconnect=true,tx_port=tcp://*:2001,rx_port=tcp://${addrs.enodebAir}:2000,id=ue,base_srate=3.84e6";
        };
      };
    };

    ctrl = {
      imports = [ common ];
      virtualisation.vlans = [ 1 2 3 4 ];

      networking.interfaces = {
        eth1.ipv4.addresses = [{ address = addrs.mmeS1; prefixLength = 24; }];
        eth2.ipv4.addresses = [
          { address = addrs.mmeCtrl; prefixLength = 24; }
          { address = addrs.smfCtrl; prefixLength = 24; }
          { address = addrs.sgwcCtrl; prefixLength = 24; }
        ];
        eth3.ipv4.addresses = [
          { address = addrs.mmeDia; prefixLength = 24; }
          { address = addrs.smfDia; prefixLength = 24; }
        ];
        eth4.ipv4.addresses = [
          { address = addrs.smfUser; prefixLength = 24; }
        ];
      };

      services.open5gs = {
        mme = {
          enable = true;
          settings = {

            mme = {
              freeDiameter = makeDiameter "mme" "dra" addrs.mmeDia;
              s1ap = mkForce [ { addr = addrs.mmeS1; } ];
              gtpc = mkForce [ { addr = addrs.mmeCtrl; } ];
            };
            sgwc.gtpc = mkForce [ { addr = addrs.sgwcCtrl; } ];
            smf.gtpc = mkForce [ { addr = addrs.smfCtrl; } ];
          };
        };

        smf = {
          enable = true;
          settings = {
            smf = {
              freeDiameter = makeDiameter "smf" "pcrf" addrs.smfDia;
              pfcp = mkForce [{ addr = addrs.smfCtrl; }];
              gtpc = mkForce [{ addr = addrs.smfCtrl; }];
              gtpu = mkForce [{ addr = addrs.smfUser; }];
              subnet = mkForce [{
                addr = "${addrs.apn}/24";
              }];
            };
            upf.pfcp = mkForce [{ addr = addrs.upfCtrl; }];
          };
        };

        sgwc = {
          enable = true;
          settings = {
            sgwc = {
              gtpc = mkForce [{ addr = addrs.sgwcCtrl; }];
              pfcp = mkForce [{ addr = addrs.sgwcCtrl; }];
            };
            sgwu.pfcp = mkForce [{ addr = addrs.sgwuCtrl; }];
          };
        };
      };
    };

    auth = {
      imports = [ common ];
      virtualisation.vlans = [ 3 ];
      networking.interfaces = {
        eth1.ipv4.addresses = [
          { address = addrs.hssDia; prefixLength = 24; }
          { address = addrs.pcrfDia; prefixLength = 24; }
        ];
      };

      services.mongodb.enable = true;

      services.open5gs = {
        hss = {
          enable = true;
          settings = {
            db_uri = "mongodb://localhost/open5gs";
            hss.freeDiameter = makeDiameter "hss" "dra" addrs.hssDia;
          };
        };

        pcrf = {
          enable = true;
          settings = {
            db_uri = "mongodb://localhost/open5gs";
            pcrf.freeDiameter = makeDiameter "pcrf" "smf" addrs.pcrfDia;
          };
        };
      };
    };

    dra = {
      imports = [ common ];
      virtualisation.vlans = [ 3 ];
      networking.interfaces = {
        eth1.ipv4.addresses = [{ address = addrs.draDia; prefixLength = 24; }];
      };
      services.freediameter = {
        enable = true;
        config = {
          identity = "dra.lte";
          realm = "lte";
          listenOn = [
            addrs.draDia
          ];
          tls = {
            cert = "/run/dra.cert.pem";
            key = "/run/dra.key.pem";
            ca = "/run/cacert.pem";
          };
          extensions = [
#{ module = "dbg_msg_dumps.fdx"; option = "0x8888"; }
          ];
          peers = [
            { peer = "mme.lte"; }
            { peer = "hss.lte"; }
          ];
        };
      };
    };

    apn = {
      imports = [ common ];
      virtualisation.vlans = [ 1 2 4 ];

      networking.interfaces = {
        eth1.ipv4.addresses = [
          { address = addrs.sgwuS1; prefixLength = 24; }
        ];
        eth2.ipv4.addresses = [
          { address = addrs.sgwuCtrl; prefixLength = 24; }
          { address = addrs.upfCtrl; prefixLength = 24; }
        ];
        eth3.ipv4.addresses = [
          { address = addrs.sgwuUser; prefixLength = 24; }
          { address = addrs.upfUser; prefixLength = 24; }
        ];
        ogstun = {
          virtual = true;
          virtualType = "tun";
          virtualOwner = "open5gs";
          ipv4.addresses = [ { address = addrs.apn; prefixLength = 24; } ];
        };
      };

      services.open5gs = {
        sgwu = {
          enable = true;
          settings = {
            sgwu = {
              pfcp = mkForce [{ addr = addrs.sgwuCtrl; }];
              gtpu = mkForce [{ addr = addrs.sgwuS1; }];
            };
          };
        };

        upf = {
          enable = true;
          settings = {
            upf = {
              pfcp = mkForce [{ addr = addrs.upfCtrl; }];
              gtpu = mkForce [{ addr = addrs.upfUser; }];
              subnet = mkForce [{
                addr = "${addrs.apn}/24";
                dev = "ogstun";
              }];
            };
          };
        };
      };
    };

  };

  testScript = ''
    dra.copy_from_host("${./keys/dra.key.pem}", "/run/dra.key.pem")
    dra.copy_from_host("${./keys/dra.cert.pem}", "/run/dra.cert.pem")
    dra.copy_from_host("${./keys/cacert.pem}", "/run/cacert.pem")
    dra.succeed("systemctl restart freediameter")
    dra.wait_for_unit("freediameter.service")

    ctrl.copy_from_host("${./keys/smf.key.pem}", "/run/smf.key.pem")
    ctrl.copy_from_host("${./keys/smf.cert.pem}", "/run/smf.cert.pem")
    ctrl.copy_from_host("${./keys/mme.key.pem}", "/run/mme.key.pem")
    ctrl.copy_from_host("${./keys/mme.cert.pem}", "/run/mme.cert.pem")
    ctrl.copy_from_host("${./keys/cacert.pem}", "/run/cacert.pem")

    auth.copy_from_host("${./keys/hss.key.pem}", "/run/hss.key.pem")
    auth.copy_from_host("${./keys/hss.cert.pem}", "/run/hss.cert.pem")
    auth.copy_from_host("${./keys/pcrf.key.pem}", "/run/pcrf.key.pem")
    auth.copy_from_host("${./keys/pcrf.cert.pem}", "/run/pcrf.cert.pem")
    auth.copy_from_host("${./keys/cacert.pem}", "/run/cacert.pem")

    auth.wait_for_unit("open5gs-hss.service")
    auth.succeed("${pkgs.open5gs}/bin/open5gs-dbctl add 001010123456780 00112233445566778899aabbccddeeff 63bfa50ee6523365ff14c1f45f88737d");

    apn.wait_for_unit("open5gs-upf.service")

    enodeb.wait_for_unit("srsran-enodeb")

    ue.wait_for_unit("srsran-ue");
    ue.wait_until_succeeds("ping -c1 10.20.10.254", timeout=300);
  '';
}
