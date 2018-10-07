{ config, lib, pkgs, ... }:

{
  # rem-specific desktop configuration
  home-manager.users.kevin = {
    home.file.".config/sway/config".text = builtins.readFile ./sway;
  };
}
