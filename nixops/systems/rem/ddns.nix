{ config, lib, pkgs, ... }:

{
  systemd.services.ddns = {
    description = "Dynamic DNS for Hurricane Electric";
    path = [ pkgs.curl ];
    script = builtins.readFile ../../secrets/ddns-curl.sh;
    startAt = "*:0/5";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}
