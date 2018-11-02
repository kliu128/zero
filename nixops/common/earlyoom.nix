{ config, lib, pkgs, ... }:

{
  services.earlyoom.enable = true;
  services.earlyoom.freeMemThreshold = 4;

  # Occasionally crashes with the message:
  # > Could not convert number: Numerical result out of range
  # So just have it restart afterward.
  systemd.services.earlyoom.serviceConfig.Restart = "always";
}