{ config, pkgs, lib, ... }:

{
  networking.networkmanager.enable = lib.mkForce true;
  networking.networkmanager.extraConfig = ''
    [main]
    rc-manager=resolvconf

    [device]
    wifi.backend=iwd
  '';
  networking.wireless.iwd.enable = true;
  users.extraUsers.kevin.extraGroups = [ "networkmanager" ];
  services.fail2ban.enable = lib.mkForce false;
}
