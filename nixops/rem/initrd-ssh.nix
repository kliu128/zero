{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "e1000e" ];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      hostRSAKey = ../secrets/rem-dropbear-ssh-key;
      port = 843;
      authorizedKeys = [
        # Laptop is able to ssh in and unlock
        (import ../ssh-keys.nix).kevin-emilia
      ];
    };
  };
}