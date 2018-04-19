{ config, lib, pkgs, ... }:

{
  # Disable adding/removing users on the fly
  users.mutableUsers = false;
  users.users.root.hashedPassword = builtins.readFile ../secrets/password-hash.txt;
  users.extraUsers.kevin = {
    description = "Kevin Liu";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    hashedPassword = builtins.readFile ../secrets/password-hash.txt;
  };
  security.sudo.enable = true;
}