{ config, lib, pkgs, ... }:

{
  services.tor = {
    enable = true;
    relay = {
      enable = true;
      role = "bridge";
      port = 9001;
      nickname = "potatorelay";
      contactInfo = "kevin@potatofrom.space";
    };
  };
  networking.firewall.allowedTCPPorts = [ 9001 ];
}