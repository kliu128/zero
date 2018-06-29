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
    syncPasswordsByPam = true;
    nsswins = true;
    shares = {
      storage = {
        "browseable" = "yes";
        "path" = "/mnt/storage";
        "read only" = false;
        "acl allow execute always" = true; # Allow executing EXEs from network
      };
      pluralsight = {
        "browseable" = "yes";
        "guest ok" = "yes"; # allow anybody to view
        "path" = "/mnt/storage/Kevin/Videos/Pluralsight";
        "read only" = true;
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
}