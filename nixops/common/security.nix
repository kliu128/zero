{ config, lib, pkgs, ... }:

{
  security.hideProcessInformation = true;
  boot.kernel.sysctl."kernel.dmesg_restrict" = 1;
}
