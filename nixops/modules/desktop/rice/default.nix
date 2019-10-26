{ config, lib, pkgs, ... }:

{
  programs.sway.enable = true;
  programs.sway.extraSessionCommands = ''
    export MOZ_ENABLE_WAYLAND=1
    export _JAVA_AWT_WM_NONREPARENTING=1
  '';
  services.xserver.displayManager.extraSessionFilePackages = [ pkgs.sway ];

  environment.systemPackages = with pkgs; [
    dunst grim slurp waybar kitty redshift xss-lock networkmanagerapplet
  ];

  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.package = pkgs.i3-gaps;

  networking.firewall.allowedTCPPorts = [ 5901 24800 ];

  home-manager.users.kevin = {
    home.file = {
      ".config/dunst/dunstrc".source = ./dunst/dunstrc;
      ".config/kitty/kitty.conf".source = ./kitty.conf;
      ".config/sway/config".text = builtins.readFile ./sway/config;
      ".config/sway/wallpaper.jpg".source = ./sway/wallpaper.jpg;
      ".config/waybar/config".source = ./waybar/config;
      ".config/waybar/style.css".source = ./waybar/style.css;
    };
  };
}
