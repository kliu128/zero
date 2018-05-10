{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedUDPPorts = [ 6666 ];
  systemd.services.netconsole-receiver = {
    enable = true;
    path = [ pkgs.netcat-gnu ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      nc -u -v -l -p 6666
    '';
    serviceConfig.DynamicUser = true;
  };
}