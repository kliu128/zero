{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 2222 19000 19001 ];
  services.stunnel = {
    enable = false;
    servers.ssh = {
      accept = 2222;
      connect = 843;
      cert = ../secrets/stunnel.pem;
    };
  };
}
