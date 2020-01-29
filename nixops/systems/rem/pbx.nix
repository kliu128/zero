{ config, lib, pkgs, ... }:

{
  systemd.services.pbx = {
    enable = true;
    description = "PBX systemd-nspawn";
    path = [ pkgs.systemd ];
    script = "systemd-nspawn -b -D /var/lib/machines/pbx";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
  networking.firewall.allowedUDPPorts = [ 5060 ];
  networking.firewall.allowedTCPPorts = [ 5060 ];
  networking.firewall.allowedUDPPortRanges = [
    # SIP signalling
    { from = 10000; to = 20000; }
  ];
}
