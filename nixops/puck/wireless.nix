{ config, pkgs, lib, ... }:

{
  networking.networkmanager.enable = true;
  users.extraUsers.kevin.extraGroups = [ "networkmanager" ];
  services.fail2ban.enable = lib.mkForce false;
}
