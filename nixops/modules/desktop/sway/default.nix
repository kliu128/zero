{ config, lib, pkgs, ... }:

{
  programs.sway-beta.enable = true;
  programs.sway-beta.extraSessionCommands = ''
    export GDK_BACKEND=x11
    export SDL_VIDEODRIVER=wayland
    # Fix for some Java AWT applications (e.g. Android Studio),
    # use this if they aren't displayed properly:
    export _JAVA_AWT_WM_NONREPARENTING=1
  '';
  home-manager.users.kevin = {
    home.file.".config/sway/config".text = builtins.readFile ./config;
    home.file.".local/bin/bar.sh" = {
      text = builtins.readFile ./conky-bar.sh;
      executable = true;
    };
  };
  services.xserver.displayManager.sddm.enable = true;
}