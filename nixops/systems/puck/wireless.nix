{ config, pkgs, lib, ... }:

{
  users.extraUsers.kevin.extraGroups = [ "networkmanager" ];
  services.fail2ban.enable = lib.mkForce false;
}
