{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dunst kitty xss-lock networkmanagerapplet
  ];

  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.package = pkgs.i3-gaps;

  networking.firewall.allowedTCPPorts = [ 5901 24800 ];

  home-manager.users.kevin = {
    home.file = {
      ".config/dunst/dunstrc".source = ./dunst/dunstrc;
      ".config/kitty/kitty.conf".source = ./kitty.conf;
    };
  };
}
