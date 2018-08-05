{ config, lib, pkgs, ... }:

{
  services.earlyoom.enable = true;
  services.earlyoom.freeMemThreshold = 5; # ~1 GB for rem, or 400 MB for puck

  # Occasionally crashes with the message:
  # > Could not convert number: Numerical result out of range
  # So just have it restart afterward.
  systemd.services.earlyoom.serviceConfig.Restart = "always";
}