{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./odr-audioenc.nix
    ./odr-dabmux.nix
    ./odr-dabmod.nix
  ];

  options.services.odr.enable = mkEnableOption "Opendigital Radio components";

  config = mkIf config.services.odr.enable {

    # No need to run as root
    users.users.odruser = {
      description   = "ODR daemon user";
      isSystemUser  = true;
      group         = "odrgroup";
    };

    users.groups.odrgroup = {};
  };
}

