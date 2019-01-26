{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl."kernel.dmesg_restrict" = 1;
}
