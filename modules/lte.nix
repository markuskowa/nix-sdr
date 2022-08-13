{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.srsran;

in {
  imports = [
    ./srsepc.nix
    ./srsenb.nix
    ./srsue.nix
  ];

  options.services.srsran = {
    nitb = {
      enable = mkEnableOption "SRSRAN LTE NITB";
    };

    mcc = mkOption {
      description = "Mobile Country Code";
      type = types.str;
      default = "001";
    };

    mnc = mkOption {
      description = "Mobile Network Code";
      type = types.str;
      default = "01";
    };
  };

  config = mkIf cfg.nitb.enable {
    services.srsran = {
      epc.enable = true;
      enodeb.enable = true;
    };

    networking.nat = {
      enable = true;
      internalInterfaces = [ "srs_spgw_sgi" ];
    };
  };
}
