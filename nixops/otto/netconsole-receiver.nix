{ config, lib, pkgs, ... }:

{
  systemd.services.netconsole-receiver = {
    enable = true;
    description = "Netconsole receiver for remote logging";
    path = [ pkgs.netcat ];
    script = ''
      nc -u -l 6666
    '';
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}
