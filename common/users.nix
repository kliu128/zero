{ config, lib, pkgs, ... }:

{
  # Disable adding/removing users on the fly
  users.mutableUsers = false;
# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.hashedPassword = "***REMOVED***";
  users.extraUsers.kevin = {
    description = "Kevin Liu";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    hashedPassword = "***REMOVED***";
  };
  security.sudo.enable = true;
}