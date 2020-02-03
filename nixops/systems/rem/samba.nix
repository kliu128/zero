{ config, lib, pkgs, ... }:

{
  # For file sharing between Windows VM and host and for Pluralsight sharing
  # with mom
  services.samba = {
    enable = true;
    extraConfig = ''
      security = user
      map to guest = Bad User
    '';
    syncPasswordsByPam = false;
    nsswins = false;
    shares = {
      storage = {
        "browseable" = "yes";
        "path" = "/mnt/storage";
        "read only" = false;
        "acl allow execute always" = true; # Allow executing EXEs from network
        "allow hosts" = "192.168.1. 10.99.0.4";
      };
      home = {
        "browseable" = "yes";
        "path" = "/home/kevin";
        "read only" = false;
        "acl allow execute always" = true; # Allow executing EXEs from network
        "allow hosts" = "10.99.0.4"; # you only
      };
      pluralsight = {
        "browseable" = "yes";
        "guest ok" = "yes"; # allow anybody to view
        "path" = "/mnt/storage/Kevin/Videos/Pluralsight";
        "read only" = true;
        "allow hosts" = "192.168.1.";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
}