{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "r8169" ];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      hostRSAKey = ../secrets/otto-dropbear-ssh-key;
      port = 844;
      authorizedKeys = [
        (import ../ssh-keys.nix).ssh-unlocker
      ];
    };
  };
}
