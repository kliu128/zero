{ config, lib, pkgs, ... }:

# Java runtime and development

let
  jdk = pkgs.adoptopenjdk-openj9-bin-11;
in {
  home-manager.users.kevin = {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
}
