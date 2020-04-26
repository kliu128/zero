{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "kevin";
    group = "users";
    dataDir = "/home/kevin/.config/syncthing";
    openDefaultPorts = true;
  };
}
