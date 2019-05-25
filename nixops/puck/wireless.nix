{ config, pkgs, lib, ... }:

{
  networking.networkmanager.enable = lib.mkForce true;
  networking.networkmanager.extraConfig = ''
    [main]
    rc-manager=resolvconf
  '';
  users.extraUsers.kevin.extraGroups = [ "networkmanager" ];
  services.fail2ban.enable = lib.mkForce false;
}
