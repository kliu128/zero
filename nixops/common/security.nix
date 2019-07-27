{ config, lib, pkgs, ... }:

{
  security.hideProcessInformation = true;
  users.extraUsers.kevin.extraGroups = [ "proc" ];
  
  boot.kernel.sysctl."kernel.dmesg_restrict" = 1;
  boot.kernel.sysctl."kernel.core_pattern" = "|${pkgs.coreutils}/bin/false";

  services.earlyoom.enable = true;
  services.earlyoom.freeSwapThreshold = 40;
}
