{ config, lib, pkgs, ... }:

{
  # Self-monitoring
  services.vnstat.enable = true;
  services.uptimed.enable = true;
  environment.systemPackages = [ pkgs.vnstat pkgs.uptimed ];

  # Monitoring of OpenWRT router through network logging (UDP port 514)
  networking.firewall.allowedUDPPorts = [ 514 ];
  services.rsyslogd = {
    enable = true;
    extraConfig = ''
      module(load="imudp")
      module(load="omjournal") 

      ruleset(name="remote") {
        action(type="omjournal")
      }

      input(type="imudp" port="514" ruleset="remote")
    '';
  };
}