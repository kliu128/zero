{ config, lib, pkgs, ... }:

{
  programs.sway.enable = true;
  programs.sway.extraSessionCommands = ''
    export MOZ_ENABLE_WAYLAND=1
    export _JAVA_AWT_WM_NONREPARENTING=1
  '';

  environment.systemPackages = with pkgs; [
    dunst grim slurp waybar kitty redshift xss-lock
  ];

  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.extraSessionCommands = ''
    xrandr --newmode "x11vnc" 83.50  1280 1352 1480 1680  800 803 809 831 -hsync +vsync
    xrandr --addmode DP-1 x11vnc
    xrandr --output DP-1 --mode x11vnc --right-of DVI-D-1
  '';
  services.xserver.windowManager.i3.package = pkgs.i3-gaps;

  networking.firewall.allowedTCPPorts = [ 5901 24800 ];
  services.synergy.server = {
    enable = true;
    configFile = pkgs.writeText "synergy.conf" ''
      section: screens
        rem:
        superolddell:
      end

      section: links
        rem:
          right = superolddell
        superolddell:
          left = rem
      end
    '';
  };

  home-manager.users.kevin = {
    services.redshift = {
      enable = true;
      latitude = "42";
      longitude = "-71";
    };
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
