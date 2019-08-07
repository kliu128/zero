{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];

  # Ignore power key (thank you kunal)
  services.logind.extraConfig = "HandlePowerKey=ignore";
}
