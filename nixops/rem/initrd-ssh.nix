{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "e1000e" ];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      hostRSAKey = ../secrets/rem-dropbear-ssh-key;
      port = 844;
      authorizedKeys = [
        # Laptop is able to ssh in and unlock
        (import ../ssh-keys.nix).kevin-emilia-rsa
      ];
    };
  };
  systemd.services.remove-eth0-ip = {
    enable = true;
    path = [ pkgs.iproute ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ip addr del 192.168.1.5/24 dev eth0
    '';
    serviceConfig.RemainAfterExit = true;
    serviceConfig.Type = "oneshot";
  };
}
