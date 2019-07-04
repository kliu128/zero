{ config, lib, pkgs, ... }:

{
  systemd.services.coder = {
    enable = true;
    description = "VSCode Coder Service";
    path = [ pkgs.systemd ];
    script = "systemd-nspawn -bUD /var/lib/machines/coder";
    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 8443 3000 8545 9545 ];
}