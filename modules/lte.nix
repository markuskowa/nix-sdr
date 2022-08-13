{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./srsepc.nix
    ./srsenb.nix
    ./srsue.nix
  ];

  options.services.srsran = {
    nitb = {
      enable = mkEnableOption "SRSRAN LTE NITB";

      earfcn = mkOption {
        description = "Frequency code (see https://www.sqimway.com/lte_band.php)";
        type = types.int;
        default = 1906; # 1875.6 DL, 1780.6 UL
      };
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
}
