{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 2222 ];
  services.stunnel = {
    enable = true;
    servers.ssh = {
      accept = 2222;
      connect = 843;
      cert = ../secrets/stunnel.pem;
    };
  };
}
