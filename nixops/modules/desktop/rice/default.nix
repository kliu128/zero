{ config, lib, pkgs, ... }:

{
  programs.sway.enable = true;
  programs.sway.extraSessionCommands = ''
    export MOZ_ENABLE_WAYLAND=1
  '';

  environment.systemPackages = with pkgs; [
    dunst grim slurp waybar kitty redshift
  ];

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
