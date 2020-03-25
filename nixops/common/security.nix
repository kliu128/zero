{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl."kernel.core_pattern" = "|${pkgs.coreutils}/bin/false";

  services.earlyoom.enable = true;
  services.earlyoom.freeSwapThreshold = 40;

  security.rngd.enable = false;
}
