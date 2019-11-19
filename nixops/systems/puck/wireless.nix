{ config, pkgs, lib, ... }:

{
  services.networkmanager.enable = true;
  users.extraUsers.kevin.extraGroups = [ "networkmanager" ];
  services.fail2ban.enable = lib.mkForce false;
}
