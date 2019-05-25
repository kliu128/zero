{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl."kernel.dmesg_restrict" = 1;
  boot.kernel.sysctl."kernel.core_pattern" = "|${pkgs.coreutils}/bin/false";
}
