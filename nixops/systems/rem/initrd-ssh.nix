{ config, lib, pkgs, ... }:

{
  # boot.initrd.availableKernelModules = [ "e1000e" ];
  # boot.initrd.network = {
  #   enable = true;
  #   ssh = {
  #     enable = true;
  #     hostRSAKey = ../../secrets/rem-dropbear-ssh-key;
  #     port = 844;
  #     authorizedKeys = [
  #       # Laptop is able to ssh in and unlock
  #       (import ../../ssh-keys.nix).yubikey
  #       (import ../../ssh-keys.nix).yubikey-backup
  #     ];
  #   };
  #   postCommands = ''
  #     echo "zfs load-key -a; killall zfs" >> /root/.profile
  #   '';
  # };
}
