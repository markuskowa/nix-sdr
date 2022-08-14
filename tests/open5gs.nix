{ pkgs, lib, ... } :

let
  user_db = pkgs.writeText "user_db.csv" ''
    ue,mil,001010123456780,00112233445566778899aabbccddeeff,opc,63bfa50ee6523365ff14c1f45f88737d,8000,000000001234,7,dynamic
  '';

  common = {
    imports = [ ../modules/lte.nix ];
    networking.firewall.enable = false;
  };

in {
  name = "open5gs-nitb";

  nodes = {
    nitb = {
      imports = [ ../modules/lte.nix ];

      services.open5gs.nitb.enable = true;
    };
  };

  testScript = ''
  '';
}
