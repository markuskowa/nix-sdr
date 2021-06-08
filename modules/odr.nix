{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./odr-audioenc.nix
    ./odr-dabmux.nix
    ./odr-dabmod.nix
  ];
}

